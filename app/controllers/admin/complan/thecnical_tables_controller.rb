class Admin::Complan::ThecnicalTablesController < Admin::Complan::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:index]
  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]

  def index
    search(params)
    @thecnical_tables = Kaminari.paginate_array(@thecnical_tables).page(params[:page]).per(20)
  end

  def new
    @thecnical_table = @model.new
  end

  def edit
  end

  def create
    @thecnical_table=  @model.new(thecnical_table_strong_params)
    if @thecnical_table.save
      audit_create(@thecnical_table)
      redirect_to admin_complan_thecnical_tables_path,  notice: I18n.t("admin.complan.thecnical_table.create_success")
    else
      flash[:error] = I18n.t("admin.complan.thecnical_table.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.complan.thecnical_table.create_error")
    redirect_to admin_complan_thecnical_tables_path
  end

  def update
    if @thecnical_table.update(thecnical_table_strong_params)
      audit_update(@thecnical_table)
      redirect_to admin_complan_thecnical_tables_path,  notice: I18n.t("admin.complan.thecnical_table.update_success")
    else
      flash[:error] = I18n.t("admin.complan.thecnical_table.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.complan.thecnical_table.update_error")
    redirect_to admin_complan_thecnical_tables_path    
  end

  def destroy
    id = @technical_table.id
    if @thecnical_table.destroy
      audit_delete("thecnical_table", id, "parbudget")
      redirect_to admin_complan_thecnical_tables_path,  notice: I18n.t("admin.complan.thecnical_table.destroy_success")
    else
      flash[:error] = I18n.t("admin.complan.thecnical_table.destroy_error")
      redirect_to admin_complan_thecnical_tables_path(errors: @thecnical_table.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.complan.thecnical_table.destroy_error")
    redirect_to admin_complan_thecnical_tables_path
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @thecnical_table.denomination,
        layout: 'pdf.html',
        page_size: 'A4',
        encoding: "UTF-8"
      end
    end
  end

  private 

  def get_model
    @model = ::Complan::ThecnicalTable
  end

  def thecnical_table_strong_params
    params.require(:complan_thecnical_table).permit(:denomination, :code, :year,:web_title,:votes, :cost, :author, :complan_ambit_id,
      :email, :phone, :url, :descriptive_memory, :complan_topic_id, :entity, :complan_responsible_id, :status,
      :plate_proceeds, :license_plate, :plate_installed, :code_old, :complan_thecnical_table_ids => [],
      :complan_economic_budgets_attributes=> [:id, :year, :import, :start_date, :end_date, :count_managing_body, :count_functional,
        :economic,:element_pep,:thecnical_table,:type_contract,:_destroy], :complan_medias_attributes => [:id, :title, :text_document, 
        :attachment,  :_destroy], :complan_links_attributes => [:id,:url, :_destroy])
  end

  def load_resource
    @thecnical_table = @model.find(params[:id])
  rescue
    @thecnical_table = nil
  end

  def load_thecnical_table
    @thecnical_tables = ::Parbudget::Financing.all
    @ambits = ::Parbudget::Ambit.all.select(:id, :name, :code)
    @topics = ::Parbudget::Topic.all.select(:id,:name)
    @responsibles = ::Parbudget::Responsible.all.select(:id, :full_name)
    @status = [
      [I18n.t('admin.complan.thecnical_table.status.definition'),I18n.t('admin.complan.thecnical_table.status.definition')],
      [I18n.t('admin.complan.thecnical_table.status.contract'),I18n.t('admin.complan.thecnical_table.status.contract')],
      [I18n.t('admin.complan.thecnical_table.status.exec'),I18n.t('admin.complan.thecnical_table.status.exec')],
      [I18n.t('admin.complan.thecnical_table.status.finished'),I18n.t('admin.complan.thecnical_table.status.finished')],
      [I18n.t('admin.complan.thecnical_table.status.invalid'),I18n.t('admin.complan.thecnical_table.status.invalid')]
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
    @thecnical_tables = @model.all
    @filters = []

    begin
      if !params[:subnav].blank? && params[:subnav].to_s != "all"
        @thecnical_tables = @thecnical_tables.where(year: params[:subnav])
      end
    rescue
    end

    begin
      if !parametrize[:search_identificator].blank?
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_identificator')}: #{parametrize[:search_identificator]}")
        @thecnical_tables = @thecnical_tables.where("translate(UPPER(cast(code as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_identificator]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_title].blank?
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_title')}: #{parametrize[:search_title]}")
        @thecnical_tables = @thecnical_tables.where("translate(UPPER(cast(web_title as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_title]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
          translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_title]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_memory].blank?
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_memory')}: #{parametrize[:search_memory]}")
        @thecnical_tables = @thecnical_tables.where("translate(UPPER(cast(descriptive_memory as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_memory]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_status].blank?
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_status')}: #{parametrize[:search_status]}")
        @thecnical_tables = @thecnical_tables.where("translate(UPPER(cast(status as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_status]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_thecnical_table].blank?
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_thecnical_table')}: #{parametrize[:search_thecnical_table]}")
        @thecnical_tables = @thecnical_tables.where("id in (?)", ::Parbudget::Financing.where("translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_thecnical_table]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')").select(:complan_thecnical_table_id))
      end
    rescue
    end

    begin
      if !parametrize[:search_year_to].blank? && !parametrize[:search_year_end].blank?
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_year_to')}: #{parametrize[:search_year_to]}")
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_year_end')}: #{parametrize[:search_year_end]}")
        @thecnical_tables = @thecnical_tables.where("year BETWEEN ? AND ?", parametrize[:search_year_to], parametrize[:search_year_end])
      elsif !parametrize[:search_year_to].blank?
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_year_to')}: #{parametrize[:search_year_to]}")
        @thecnical_tables = @thecnical_tables.where("date_at >= ?", parametrize[:search_year_to])
      elsif !parametrize[:search_year_end].blank?
        @filters.push("#{I18n.t('admin.complan.thecnical_table.search_year_end')}: #{parametrize[:search_year_end]}")
        @thecnical_tables = @thecnical_tables.where("date_at <= ?", parametrize[:search_year_end])
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @thecnical_tables = @thecnical_tables.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @thecnical_tables = @thecnical_tables.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @thecnical_tables = @thecnical_tables.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @thecnical_tables = []
    @filters = []
  end
end
