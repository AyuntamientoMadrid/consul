class CommentsController < ApplicationController
  include CustomUrlsHelper

  before_action :authenticate_user!, only: :create
  before_action :load_commentable, only: :create
  before_action :verify_resident_for_commentable!, only: :create
  before_action :verify_comments_open!, only: [:create, :vote]
  before_action :build_comment, only: :create

  load_and_authorize_resource
  respond_to :html, :js

  def create
    if @comment.save
      CommentNotifier.new(comment: @comment).process
      add_notification @comment
      auto_moderate_comment @comment
      log_comment_event
    else
      render :new
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def show
    @comment = Comment.find(params[:id])
    if @comment.valuation && @comment.author != current_user
      raise ActiveRecord::RecordNotFound
    else
      set_comment_flags(@comment.subtree)
    end
  end

  def update
    @comment = Comment.find(params[:id])
    original_matches = @comment.moderated_texts.map(&:text)

    if @comment.update(comment_params)
      new_matches = @comment.check_for_offenses

      removed_offenses = original_matches - new_matches
      added_offenses = new_matches - original_matches

      if new_matches.empty?
        remove_offenses(@comment)
        @comment.is_offensive = false
        redirect_to user_path(current_user, filter: "comments"), notice: t("flash.actions.update.comment")
      else
        remove_offenses(@comment, removed_offenses)
        auto_moderate_comment(@comment, added_offenses)
        redirect_to edit_comment_path(@comment), notice: t("flash.actions.update.comment")
      end
    end
  end

  def vote
    @comment.vote_by(voter: current_user, vote: params[:value])
    respond_with @comment
  end

  def flag
    Flag.flag(current_user, @comment)
    set_comment_flags(@comment)
    respond_with @comment, template: "comments/_refresh_flag_actions"
  end

  def unflag
    Flag.unflag(current_user, @comment)
    set_comment_flags(@comment)
    respond_with @comment, template: "comments/_refresh_flag_actions"
  end

  private

    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, :parent_id,
                                      :body, :as_moderator, :as_administrator, :valuation)
    end

    def build_comment
      @comment = Comment.build(@commentable, current_user, comment_params[:body],
                               comment_params[:parent_id].presence,
                               comment_params[:valuation])
      check_for_special_comments
    end

    def check_for_special_comments
      if administrator_comment?
        @comment.administrator_id = current_user.administrator.id
      elsif moderator_comment?
        @comment.moderator_id = current_user.moderator.id
      end
    end

    def load_commentable
      @commentable = Comment.find_commentable(comment_params[:commentable_type],
                                              comment_params[:commentable_id])
    end

    def administrator_comment?
      ["1", true].include?(comment_params[:as_administrator]) &&
        can?(:comment_as_administrator, @commentable)
    end

    def moderator_comment?
      ["1", true].include?(comment_params[:as_moderator]) &&
        can?(:comment_as_moderator, @commentable)
    end

    def add_notification(comment)
      notifiable = comment.reply? ? comment.parent : comment.commentable
      notifiable_author_id = notifiable.try(:author_id)
      if notifiable_author_id.present? && notifiable_author_id != comment.author_id
        Notification.add(notifiable.author, notifiable)
      end
    end

    def verify_resident_for_commentable!
      return if current_user.administrator? || current_user.moderator?

      if @commentable.respond_to?(:comments_for_verified_residents_only?) &&
         @commentable.comments_for_verified_residents_only?
        verify_resident!
      end
    end

    def verify_comments_open!
      return if current_user.administrator? || current_user.moderator?

      if @commentable.respond_to?(:comments_closed?) && @commentable.comments_closed?
        redirect_to @commentable, alert: t("comments.comments_closed")
      end
    end

    def log_comment_event
      return unless @comment.commentable_type == "Proposal"
      if @comment.root?
        log_event("proposal", "comment")
      else
        log_event("proposal", "comment_reply")
      end
    end

    def auto_moderate_comment(comment, matches = nil)
      if matches.nil?
        offensive_matches = comment.check_for_offenses
        return if offensive_matches.nil? || offensive_matches.empty?
        build_records(comment, offensive_matches)
      else
        build_records(comment, matches)
      end

      ::ModeratedContent.import(@moderated_records)
      comment.is_offensive = true
    end

    def build_records(comment, matches)
      matched_ids = ::ModeratedText.get_word_ids(matches)
      @moderated_records = []

      matched_ids.each do |id|
        @moderated_records.push(
          ::ModeratedContent.new(
            moderable_type: comment.class.to_s,
            moderated_text_id: id,
            moderable_id: comment.id
          )
        )
      end

      return @moderated_records
    end

    def remove_offenses(comment, words = nil)
      klass = comment.class.to_s

      if words.nil?
        ::ModeratedContent.remove_all_offenses(comment.id, klass)
      else
        word_ids = ::ModeratedText.get_word_ids(words)
        ::ModeratedContent.remove_specific_offenses(klass, word_ids, comment.id)
      end
    end
end
