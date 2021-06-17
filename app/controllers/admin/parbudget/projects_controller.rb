class Admin::Parbudget::ProjectsController < Admin::Parbudget::BaseController
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:index]
  before_action :load_center

  def index
    search(params)
    @projects = @projects.page(params[:page]).per(20)
  end

  def new
    @project = ::Parbudget::Project.new
  end

  def edit
  end

  def create
    @project=  @model.new(project_strong_params)
    if @project.save
      redirect_to admin_parbudget_projects_path,  notice: I18n.t("admin.parbudget.project.create_success")
    else
      flash[:error] = I18n.t("admin.parbudget.project.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.project.create_error")
    redirect_to admin_parbudget_projects_path
  end

  def update
    if @project.update(project_strong_params)
      if project_strong_params[:parbudget_center_ids].blank?
        @project.parbudget_centers.each do |center|
          center.parbudget_project_id = nil
          center.save(validate: false)
        end
        @project.parbudget_centers = []
        @project.save
      end
      redirect_to admin_parbudget_projects_path,  notice: I18n.t("admin.parbudget.project.update_success")
    else
      flash[:error] = I18n.t("admin.parbudget.project.update_error")
      render :edit
    end
  # rescue
  #   flash[:error] = I18n.t("admin.parbudget.project.update_error")
  #   redirect_to admin_parbudget_projects_path    
  end

  def destroy
    if @project.destroy
      redirect_to admin_parbudget_projects_path,  notice: I18n.t("admin.parbudget.project.destroy_success")
    else
      flash[:error] = I18n.t("admin.parbudget.project.destroy_error")
      redirect_to admin_parbudget_projects_path(errors: @project.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.project.destroy_error")
    redirect_to admin_parbudget_projects_path
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @project.denomination,
        layout: 'pdf.html',
        page_size: 'A4',
        encoding: "UTF-8"
      end
    end
  end

  private 

  def get_model
    @model = ::Parbudget::Project
  end

  def project_strong_params
    params.require(:parbudget_project).permit(:denomination, :code, :year,:web_title,:votes, :cost, :author, :parbudget_ambit_id,
      :email, :phone, :url, :descriptive_memory, :parbudget_topic_id, :entity, :parbudget_responsible_id, :status,
      :plate_proceeds, :license_plate, :plate_installed, :code_old, :parbudget_center_ids => [],
      :parbudget_economic_budgets_attributes=> [:id, :year, :import, :start_date, :end_date, :count_managing_body, :count_functional,
        :economic,:element_pep,:financing,:type_contract,:_destroy], :parbudget_medias_attributes => [:id, :title, :text_document, 
        :attachment,  :_destroy], :parbudget_links_attributes => [:id,:url, :_destroy])
  end

  def load_resource
    @project = @model.find(params[:id])
  rescue
    @project = nil
  end

  def load_center
    @centers = ::Parbudget::Center.all
    @ambits = ::Parbudget::Ambit.all.select(:id, :name, :code)
    @topics = ::Parbudget::Topic.all.select(:id,:name)
    @responsibles = ::Parbudget::Responsible.all.select(:id, :full_name)
  end

  def load_data
    @status = []
    @subnav = [{title: "Todos",value: "all"}]
    @model.pluck(:year).uniq.each do |year|
      @subnav.push({title: "Año #{year}",value: year.to_s})
    end
  end

  def search(parametrize = {})
    @projects = @model.all
    @filters = []

    if !params[:subnav].blank? && params[:subnav].to_s != "all"
      @projects = @projects.where(year: params[:subnav])
    end

    begin
      if !parametrize[:search_identificator].blank?
        @filters.push("#{I18n.t('admin.parbudget.ambit.search_identificator')}: #{parametrize[:search_identificator]}")
        @projects = @projects.where("translate(UPPER(cast(code as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_identificator]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_title].blank?
        @filters.push("#{I18n.t('admin.parbudget.ambit.search_title')}: #{parametrize[:search_title]}")
        @projects = @projects.where("translate(UPPER(cast(web_title as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_title]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
          translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_title]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_memory].blank?
        @filters.push("#{I18n.t('admin.parbudget.ambit.search_memory')}: #{parametrize[:search_memory]}")
        @projects = @projects.where("translate(UPPER(cast(descriptive_memory as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_memory]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_status].blank?
        @filters.push("#{I18n.t('admin.parbudget.ambit.search_status')}: #{parametrize[:search_status]}")
        @projects = @projects.where("translate(UPPER(cast(status as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_status]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_center].blank?
        @filters.push("#{I18n.t('admin.parbudget.ambit.search_center')}: #{parametrize[:search_center]}")
        @projects = @projects.where("id in (?)", ::Parbudget::Center.where("translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_center]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')").select(:parbudget_project_id))
      end
    rescue
    end

    begin
      if !parametrize[:search_year_to].blank? && !parametrize[:search_year_end].blank?
        @filters.push("#{I18n.t('admin.parbudget.meeting.search_year_to')}: #{parametrize[:search_year_to]}")
        @filters.push("#{I18n.t('admin.parbudget.meeting.search_date_end')}: #{parametrize[:search_year_end]}")
        @projects = @projects.where("year BETWEEN ? AND ?", parametrize[:search_year_to], parametrize[:search_year_end])
      elsif !parametrize[:search_year_to].blank?
        @filters.push("#{I18n.t('admin.parbudget.meeting.search_year_to')}: #{parametrize[:search_year_to]}")
        @projects = @projects.where("date_at >= ?", parametrize[:search_year_to])
      elsif !parametrize[:search_year_end].blank?
        @filters.push("#{I18n.t('admin.parbudget.meeting.search_date_end')}: #{parametrize[:search_year_end]}")
        @projects = @projects.where("date_at <= ?", parametrize[:search_year_end])
      end
    rescue
    end
  rescue
    @projects = []
    @filters = []
  end
end
            