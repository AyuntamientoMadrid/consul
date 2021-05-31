class Legislation::QuestionsController < Legislation::BaseController
  load_and_authorize_resource :process
  load_and_authorize_resource :question, through: :process

  has_orders %w{most_voted newest oldest}, only: :show

  def show
    @commentable = @question
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    set_legislation_question_votes(@question)
    @answer = @question.answer_for_user(current_user) || Legislation::Answer.new
  end

  def vote
    @question.register_vote(current_user, params[:value])
    set_legislation_question_votes(@question)
    log_event("legislation_question", "vote", I18n.t("tracking.events.name.#{params[:value]}"))
  end

  private

    def set_legislation_question_votes(questions)
      @legislation_question_votes = current_user ? current_user.legislation_question_votes(questions) : {}
    end
end
