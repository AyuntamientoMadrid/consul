class Admin::Complan::StrategiesController < Admin::Complan::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_resource, only: [:update_strategy,:destroy]

  load_and_authorize_resource :strategy, class: "Complan::Strategy"

  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]
  def index
    search(params)
    @strategies = Kaminari.paginate_array(@strategies).page(params[:page]).per(20)
  end

  def create_strategy
    @strategy=  @model.new
    if @strategy.save(validate: false)
      audit_create(@strategy)
      redirect_to admin_complan_strategies_path,  notice: I18n.t("admin.complan.strategy.create_success")
    else
      flash[:error] = I18n.t("admin.complan.strategy.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.complan.strategy.create_error")
    redirect_to admin_complan_strategies_path
  end

  def update_strategy
    if @strategy.update(strategy_strong_params)
      audit_update(@strategy)
      redirect_to admin_complan_strategies_path,  notice: I18n.t("admin.complan.strategy.update_success")
    else
      flash[:error] = I18n.t("admin.complan.strategy.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.complan.strategy.update_error")
    redirect_to admin_complan_strategies_path    
  end

  def destroy
    id = @strategy.id
    if @strategy.destroy
      audit_delete("strategy", id, "parbudget")
      redirect_to admin_complan_strategies_path,  notice: I18n.t("admin.complan.strategy.destroy_success")
    else
      flash[:error] = I18n.t("admin.complan.strategy.destroy_error")
      redirect_to admin_complan_strategies_path(errors: @strategy.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.complan.strategy.destroy_error")
    redirect_to admin_complan_strategies_path
  end

  private 

  def get_model
    @model = ::Complan::Strategy
  end

  def strategy_strong_params
    params.require(:complan_strategy).permit(:name, :description, :departure, :approbal_date)
  end

  def load_resource
    @strategy = @model.find(params[:id])
  rescue
    @strategy = nil
  end

  def search(parametrize = {})
    @strategies = @model.all
    @filters = []

    begin
      if !parametrize[:search_description].blank?
        @filters.push("#{I18n.t('admin.complan.strategy.search_description')}: #{parametrize[:search_description]}")
        @strategies = @strategies.where("translate(UPPER(cast(description as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_description]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_name].blank?
        @filters.push("#{I18n.t('admin.complan.strategy.search_name')}: #{parametrize[:search_name]}")
        @strategies = @strategies.where("translate(UPPER(cast(name as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_name]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_departure].blank?
        @filters.push("#{I18n.t('admin.complan.strategy.search_departure')}: #{parametrize[:search_departure]}")
        @strategies = @strategies.where("translate(UPPER(cast(departure as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_departure]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_start_date].blank? && !parametrize[:search_end_date].blank?
        @filters.push("#{I18n.t('admin.complan.strategy.search_start_date')}: #{parametrize[:search_start_date]}")
        @filters.push("#{I18n.t('admin.complan.strategy.search_end_date')}: #{parametrize[:search_end_date]}")
        @strategies = @strategies.where("approbal_date BETWEEN ? AND ?", parametrize[:search_start_date], parametrize[:search_end_date])
      elsif !parametrize[:search_start_date].blank?
        @filters.push("#{I18n.t('admin.complan.strategy.search_start_date')}: #{parametrize[:search_start_date]}")
        @strategies = @strategies.where("approbal_date >= ?", parametrize[:search_start_date])
      elsif !parametrize[:search_end_date].blank?
        @filters.push("#{I18n.t('admin.complan.strategy.search_end_date')}: #{parametrize[:search_end_date]}")
        @strategies = @strategies.where("approbal_date <= ?", parametrize[:search_end_date])
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @strategies = @strategies.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @strategies = @strategies.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @strategies = @strategies.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @strategies = []
    @filters = []
  end
end
