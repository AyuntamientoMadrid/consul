class Admin::Complan::ProjectsController < Admin::Complan::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:index]
  before_action :load_resource, only: [:update_project,:destroy]
  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]

  load_and_authorize_resource :project, class: "Complan::Project"

  def index
    search(params)
    @projects = Kaminari.paginate_array(@projects).page(params[:page]).per(20)
  end

  def create_project
    @project=  @model.new
    if @project.save(validate: false)
      audit_create(@project)
      redirect_to admin_complan_projects_path,  notice: I18n.t("admin.complan.project.create_success")
    else
      flash[:error] = I18n.t("admin.complan.project.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.complan.project.create_error")
    redirect_to admin_complan_projects_path
  end

  def update_project
    if @project.update(project_strong_params)
      audit_update(@project)
      redirect_to admin_complan_projects_path,  notice: I18n.t("admin.complan.project.update_success")
    else
      flash[:error] = I18n.t("admin.complan.project.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.complan.project.update_error")
    redirect_to admin_complan_projects_path    
  end

  def destroy
    id = @project.id
    if @project.destroy
      audit_delete("project", id, "parbudget")
      redirect_to admin_complan_projects_path,  notice: I18n.t("admin.complan.project.destroy_success")
    else
      flash[:error] = I18n.t("admin.complan.project.destroy_error")
      redirect_to admin_complan_projects_path(errors: @project.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.complan.project.destroy_error")
    redirect_to admin_complan_projects_path
  end

  private 

  def get_model
    @model = ::Complan::Project
  end

  def project_strong_params
    params.require(:complan_project).permit(:description, :name, :complan_strategy_id)
  end

  def load_resource
    @project = @model.find(params[:id])
  rescue
    @project = nil
  end

  def load_data
    @strategies = ::Complan::Strategy.all.pluck(:name,:id) 
  end

  def search(parametrize = {})
    @projects = @model.all
    @filters = []


    begin
      if !parametrize[:search_name].blank?
        @filters.push("#{I18n.t('admin.complan.project.search_name')}: #{parametrize[:search_name]}")
        @projects = @projects.where("translate(UPPER(cast(name as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_name]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_description].blank?
        @filters.push("#{I18n.t('admin.complan.project.search_description')}: #{parametrize[:search_description]}")
        @projects = @projects.where("translate(UPPER(cast(description as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_description]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_strategy].blank?
        @filters.push("#{I18n.t('admin.complan.project.search_strategy')}: #{parametrize[:search_strategy]}")
        @projects = @projects.where("complan_strategy_id in (#{parametrize[:search_strategy]})")
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @projects = @projects.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @projects = @projects.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @projects = @projects.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @projects = []
    @filters = []
  end
end
