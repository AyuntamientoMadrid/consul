module Budgets
  class ResultsController < ApplicationController
    before_action :load_budget
    before_action :load_heading

    load_and_authorize_resource :budget

    def show
      authorize! :read_results, @budget
      @investments = Budget::Result.new(@budget, @heading).investments
    end

    private

      def load_budget
        @budget = Budget.find_by_slug_or_id(params[:budget_id]) || Budget.first
      end

      def load_heading
        if @budget.present?
          @heading = @budget.headings.find_by_slug_or_id(params[:heading_id]) || default_heading
        end
      end

      def default_heading
        @budget.city_heading || @budget.headings.first
      end

  end
end
