module Budgets
  class InvestmentsController < ApplicationController
    include FeatureFlags
    include CommentableActions
    include FlagActions

    before_action :authenticate_user!, except: [:index, :show]

    load_and_authorize_resource :budget
    load_and_authorize_resource :investment, through: :budget, class: "Budget::Investment"

    before_action -> { flash.now[:notice] = flash[:notice].html_safe if flash[:html_safe] && flash[:notice] }
    before_action :load_ballot, only: [:index, :show]
    before_action :load_heading, only: [:index, :show]
    before_action :set_random_seed, only: :index

    feature_flag :budgets

    has_orders %w{most_voted newest oldest}, only: :show
    has_orders ->(c) { c.instance_variable_get(:@budget).investments_orders }, only: :index

    invisible_captcha only: [:create, :update], honeypot: :subtitle, scope: :budget_investment

    respond_to :html, :js

    def index
      @investments = @investments.apply_filters_and_search(@budget, params).send("sort_by_#{@current_order}").page(params[:page]).per(10).for_render
      @investment_ids = @investments.pluck(:id)
      load_investment_votes(@investments)
    end

    def new
    end

    def show
      @commentable = @investment
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)
      load_investment_votes(@investment)
      @investment_ids = [@investment.id]
    end

    def create
      @investment.author = current_user

      if @investment.save
        activity_link = view_context.link_to(t('layouts.header.my_activity_link'),
                                             user_path(current_user, filter: :budget_investments))
        redirect_to budget_investment_path(@budget, @investment),
                    flash: { html_safe: true },
                    notice: t('flash.actions.create.budget_investment', activity: activity_link)
      else
        render :new
      end
    end

    def destroy
      investment.destroy
      redirect_to user_path(current_user, filter: 'budget_investments'), notice: t('flash.actions.destroy.budget_investment')
    end

    def vote
      @investment.register_selection(current_user)
      load_investment_votes(@investment)
    end

    private

      def load_investment_votes(investments)
        @investment_votes = current_user ? current_user.budget_investment_votes(investments) : {}
      end

      def set_random_seed
        if params[:order] == 'random' || params[:order].blank?
          params[:random_seed] ||= rand(99)/100.0
          Budget::Investment.connection.execute "select setseed(#{params[:random_seed]})"
        else
          params[:random_seed] = nil
        end
      end

      def investment_params
        params.require(:budget_investment).permit(:title, :description, :external_url, :heading_id, :terms_of_service, :location, :organization_name)
      end

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create : query.first_or_initialize
      end

      def load_heading
        if params[:heading_id].present?
          @heading = @budget.headings.find(params[:heading_id])
          @assigned_heading = @ballot.try(:heading_for_group, @heading.try(:group))
        end
      end

  end

end
