class Admin::Complan::PerformancesController < Admin::Complan::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:index]
  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]

  def index
    search(params)
    @performances = Kaminari.paginate_array(@performances).page(params[:page]).per(20)
  end

  def new
    @performance = @model.new
  end

  def edit
  end

  def create
    @performance=  @model.new(performance_strong_params)
    if @performance.save
      audit_create(@performance)
      redirect_to admin_complan_performances_path,  notice: I18n.t("admin.complan.performance.create_success")
    else
      flash[:error] = I18n.t("admin.complan.performance.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.complan.performance.create_error")
    redirect_to admin_complan_performances_path
  end

  def update
    if @performance.update(performance_strong_params)
      audit_update(@performance)
      redirect_to admin_complan_performances_path,  notice: I18n.t("admin.complan.performance.update_success")
    else
      flash[:error] = I18n.t("admin.complan.performance.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.complan.performance.update_error")
    redirect_to admin_complan_performances_path    
  end

  def destroy
    id = @performance.id
    if @performance.destroy
      audit_delete("performance", id, "parbudget")
      redirect_to admin_complan_performances_path,  notice: I18n.t("admin.complan.performance.destroy_success")
    else
      flash[:error] = I18n.t("admin.complan.performance.destroy_error")
      redirect_to admin_complan_performances_path(errors: @performance.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.complan.performance.destroy_error")
    redirect_to admin_complan_performances_path
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @performance.denomination,
        layout: 'pdf.html',
        page_size: 'A4',
        encoding: "UTF-8"
      end
    end
  end

  private 

  def get_model
    @model = ::Complan::Performance
  end

  def performance_strong_params
    params.require(:complan_performance).permit(:denomination, :code, :year,:web_title,:votes, :cost, :author, :complan_ambit_id,
      :email, :phone, :url, :descriptive_memory, :complan_topic_id, :entity, :complan_responsible_id, :status,
      :plate_proceeds, :license_plate, :plate_installed, :code_old, :complan_center_ids => [],
      :complan_economic_budgets_attributes=> [:id, :year, :import, :start_date, :end_date, :count_managing_body, :count_functional,
        :economic,:element_pep,:financing,:type_contract,:_destroy], :complan_medias_attributes => [:id, :title, :text_document, 
        :attachment,  :_destroy], :complan_links_attributes => [:id,:url, :_destroy])
  end

  def load_resource
    @performance = @model.find(params[:id])
  rescue
    @performance = nil
  end

  def load_center
    @centers = ::Parbudget::Center.all
    @ambits = ::Parbudget::Ambit.all.select(:id, :name, :code)
    @topics = ::Parbudget::Topic.all.select(:id,:name)
    @responsibles = ::Parbudget::Responsible.all.select(:id, :full_name)
    @status = [
      [I18n.t('admin.complan.performance.status.definition'),I18n.t('admin.complan.performance.status.definition')],
      [I18n.t('admin.complan.performance.status.contract'),I18n.t('admin.complan.performance.status.contract')],
      [I18n.t('admin.complan.performance.status.exec'),I18n.t('admin.complan.performance.status.exec')],
      [I18n.t('admin.complan.performance.status.finished'),I18n.t('admin.complan.performance.status.finished')],
      [I18n.t('admin.complan.performance.status.invalid'),I18n.t('admin.complan.performance.status.invalid')]
    ]
  end

  def load_data
    @status = []
    @subnav = [{title: "Todos",value: "all"}]
    # @model.pluck(:year).uniq.each do |year|
    #   @subnav.push({title: "Año #{year}",value: year.to_s})
    # end
  end

  def search(parametrize = {})
    @performances = @model.all
    @filters = []

    begin
      if !params[:subnav].blank? && params[:subnav].to_s != "all"
        @performances = @performances.where(year: params[:subnav])
      end
    rescue
    end

    begin
      if !parametrize[:search_identificator].blank?
        @filters.push("#{I18n.t('admin.complan.performance.search_identificator')}: #{parametrize[:search_identificator]}")
        @performances = @performances.where("translate(UPPER(cast(code as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_identificator]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_title].blank?
        @filters.push("#{I18n.t('admin.complan.performance.search_title')}: #{parametrize[:search_title]}")
        @performances = @performances.where("translate(UPPER(cast(web_title as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_title]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
          translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_title]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_memory].blank?
        @filters.push("#{I18n.t('admin.complan.performance.search_memory')}: #{parametrize[:search_memory]}")
        @performances = @performances.where("translate(UPPER(cast(descriptive_memory as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_memory]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_status].blank?
        @filters.push("#{I18n.t('admin.complan.performance.search_status')}: #{parametrize[:search_status]}")
        @performances = @performances.where("translate(UPPER(cast(status as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_status]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_center].blank?
        @filters.push("#{I18n.t('admin.complan.performance.search_center')}: #{parametrize[:search_center]}")
        @performances = @performances.where("id in (?)", ::Parbudget::Center.where("translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_center]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')").select(:complan_performance_id))
      end
    rescue
    end

    begin
      if !parametrize[:search_year_to].blank? && !parametrize[:search_year_end].blank?
        @filters.push("#{I18n.t('admin.complan.performance.search_year_to')}: #{parametrize[:search_year_to]}")
        @filters.push("#{I18n.t('admin.complan.performance.search_year_end')}: #{parametrize[:search_year_end]}")
        @performances = @performances.where("year BETWEEN ? AND ?", parametrize[:search_year_to], parametrize[:search_year_end])
      elsif !parametrize[:search_year_to].blank?
        @filters.push("#{I18n.t('admin.complan.performance.search_year_to')}: #{parametrize[:search_year_to]}")
        @performances = @performances.where("date_at >= ?", parametrize[:search_year_to])
      elsif !parametrize[:search_year_end].blank?
        @filters.push("#{I18n.t('admin.complan.performance.search_year_end')}: #{parametrize[:search_year_end]}")
        @performances = @performances.where("date_at <= ?", parametrize[:search_year_end])
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @performances = @performances.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @performances = @performances.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @performances = @performances.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @performances = []
    @filters = []
  end
end
