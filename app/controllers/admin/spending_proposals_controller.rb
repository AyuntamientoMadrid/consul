class Admin::SpendingProposalsController < Admin::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  has_filters %w{valuation_open without_admin managed valuating valuation_finished}, only: :index

  load_and_authorize_resource

  def index
    @spending_proposals = SpendingProposal.search(params, @current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
    @admins = Administrator.includes(:user).all
    @valuators = Valuator.includes(:user).all.order("users.username ASC")
  end

  def assign_admin
    @spending_proposal.update(params.require(:spending_proposal).permit(:administrator_id))
    render nothing: true
  end

  def assign_valuators
    params[:spending_proposal] ||= {}
    params[:spending_proposal][:valuator_ids] ||= []
    @spending_proposal.update(params.require(:spending_proposal).permit(valuator_ids: []))
  end

end
