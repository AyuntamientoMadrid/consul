class Admin::Complan::FinancingsController < Admin::Complan::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:index]
  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]
  
  def index
    search(params)
    @financings = Kaminari.paginate_array(@financings).page(params[:page]).per(20)
  end

  def new
    @financing = @model.new
  end

  def edit
  end

  def create
    @financing=  @model.new(financing_strong_params)
    if @financing.save
      audit_create(@financing)
      redirect_to admin_complan_financings_path,  notice: I18n.t("admin.complan.financing.create_success")
    else
      flash[:error] = I18n.t("admin.complan.financing.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.complan.financing.create_error")
    redirect_to admin_complan_financings_path
  end

  def update
    if @financing.update(financing_strong_params)
      audit_update(@financing)
      redirect_to admin_complan_financings_path,  notice: I18n.t("admin.complan.financing.update_success")
    else
      flash[:error] = I18n.t("admin.complan.financing.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.complan.financing.update_error")
    redirect_to admin_complan_financings_path    
  end

  def destroy
    id = @financing.id
    if @financing.destroy
      audit_delete("financing", id, "parbudget")
      redirect_to admin_complan_financings_path,  notice: I18n.t("admin.complan.financing.destroy_success")
    else
      flash[:error] = I18n.t("admin.complan.financing.destroy_error")
      redirect_to admin_complan_financings_path(errors: @financing.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.complan.financing.destroy_error")
    redirect_to admin_complan_financings_path
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @financing.denomination,
        layout: 'pdf.html',
        page_size: 'A4',
        encoding: "UTF-8"
      end
    end
  end

  private 

  def get_model
    @model = ::Complan::Financing
  end

  def financing_strong_params
    params.require(:complan_financing).permit(:denomination, :code, :year,:web_title,:votes, :cost, :author, :complan_ambit_id,
      :email, :phone, :url, :descriptive_memory, :complan_topic_id, :entity, :complan_responsible_id, :status,
      :plate_proceeds, :license_plate, :plate_installed, :code_old, :complan_financing_ids => [],
      :complan_economic_budgets_attributes=> [:id, :year, :import, :start_date, :end_date, :count_managing_body, :count_functional,
        :economic,:element_pep,:financing,:type_contract,:_destroy], :complan_medias_attributes => [:id, :title, :text_document, 
        :attachment,  :_destroy], :complan_links_attributes => [:id,:url, :_destroy])
  end

  def load_resource
    @financing = @model.find(params[:id])
  rescue
    @financing = nil
  end

  def load_financing
    @financings = ::Parbudget::Financing.all
    @ambits = ::Parbudget::Ambit.all.select(:id, :name, :code)
    @topics = ::Parbudget::Topic.all.select(:id,:name)
    @responsibles = ::Parbudget::Responsible.all.select(:id, :full_name)
    @status = [
      [I18n.t('admin.complan.financing.status.definition'),I18n.t('admin.complan.financing.status.definition')],
      [I18n.t('admin.complan.financing.status.contract'),I18n.t('admin.complan.financing.status.contract')],
      [I18n.t('admin.complan.financing.status.exec'),I18n.t('admin.complan.financing.status.exec')],
      [I18n.t('admin.complan.financing.status.finished'),I18n.t('admin.complan.financing.status.finished')],
      [I18n.t('admin.complan.financing.status.invalid'),I18n.t('admin.complan.financing.status.invalid')]
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
    @financings = @model.all
    @filters = []

    begin
      if !params[:subnav].blank? && params[:subnav].to_s != "all"
        @financings = @financings.where(year: params[:subnav])
      end
    rescue
    end

    begin
      if !parametrize[:search_identificator].blank?
        @filters.push("#{I18n.t('admin.complan.financing.search_identificator')}: #{parametrize[:search_identificator]}")
        @financings = @financings.where("translate(UPPER(cast(code as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_identificator]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_title].blank?
        @filters.push("#{I18n.t('admin.complan.financing.search_title')}: #{parametrize[:search_title]}")
        @financings = @financings.where("translate(UPPER(cast(web_title as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_title]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
          translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_title]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_memory].blank?
        @filters.push("#{I18n.t('admin.complan.financing.search_memory')}: #{parametrize[:search_memory]}")
        @financings = @financings.where("translate(UPPER(cast(descriptive_memory as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_memory]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_status].blank?
        @filters.push("#{I18n.t('admin.complan.financing.search_status')}: #{parametrize[:search_status]}")
        @financings = @financings.where("translate(UPPER(cast(status as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_status]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_financing].blank?
        @filters.push("#{I18n.t('admin.complan.financing.search_financing')}: #{parametrize[:search_financing]}")
        @financings = @financings.where("id in (?)", ::Parbudget::Financing.where("translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_financing]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')").select(:complan_financing_id))
      end
    rescue
    end

    begin
      if !parametrize[:search_year_to].blank? && !parametrize[:search_year_end].blank?
        @filters.push("#{I18n.t('admin.complan.financing.search_year_to')}: #{parametrize[:search_year_to]}")
        @filters.push("#{I18n.t('admin.complan.financing.search_year_end')}: #{parametrize[:search_year_end]}")
        @financings = @financings.where("year BETWEEN ? AND ?", parametrize[:search_year_to], parametrize[:search_year_end])
      elsif !parametrize[:search_year_to].blank?
        @filters.push("#{I18n.t('admin.complan.financing.search_year_to')}: #{parametrize[:search_year_to]}")
        @financings = @financings.where("date_at >= ?", parametrize[:search_year_to])
      elsif !parametrize[:search_year_end].blank?
        @filters.push("#{I18n.t('admin.complan.financing.search_year_end')}: #{parametrize[:search_year_end]}")
        @financings = @financings.where("date_at <= ?", parametrize[:search_year_end])
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @financings = @financings.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @financings = @financings.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @financings = @financings.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @financings = []
    @filters = []
  end
end
