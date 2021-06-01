class Admin::Parbudget::ResponsiblesController < Admin::Parbudget::BaseController
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:new,:create,:edit,:update,:index]

  def index
    search(params)
    @responsibles = @responsibles.page(params[:page]).per(20)
  end

  def new
    @responsible = @model.new
  end

  def edit
  end

  def create
    @responsible=  @model.new(responsible_strong_params)
    if @responsible.save
      redirect_to admin_parbudget_responsibles_path,  notice: I18n.t("admin.parbudget.responsible.create_success")
    else
      flash[:error] = I18n.t("admin.parbudget.responsible.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.responsible.create_error")
    redirect_to admin_parbudget_responsibles_path
  end

  def update
    if @responsible.update(responsible_strong_params)
      redirect_to admin_parbudget_responsibles_path,  notice: I18n.t("admin.parbudget.responsible.update_success")
    else
      flash[:error] = I18n.t("admin.parbudget.responsible.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.responsible.update_error")
    redirect_to admin_parbudget_responsibles_path    
  end

  def destroy
    if @responsible.destroy
      redirect_to admin_parbudget_responsibles_path,  notice: I18n.t("admin.parbudget.responsible.destroy_success")
    else
      flash[:error] = I18n.t("admin.parbudget.responsible.destroy_error")
      redirect_to admin_parbudget_responsibles_path(errors: @responsible.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.responsible.destroy_error")
    redirect_to admin_parbudget_responsibles_path
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        
        render pdf: @responsible.full_name,
        layout: 'pdf.html',
        page_size: 'A4',
        encoding: "UTF-8"
       
      end
    end
  end

  private 

  def get_model
    @model = ::Parbudget::Responsible
  end

  def load_data
    @centers = ::Parbudget::Center.all
    @subnav = [{title: "Todos",value: "all"}]
    @model.pluck(:parbudget_center_id).uniq.each do |center|
      @subnav.push({title: ::Parbudget::Center.find_by(id: center).try(:denomination),value: center.to_s})
    end
  end

  def responsible_strong_params
    params.require(:parbudget_responsible).permit(:full_name, :email, :phone, :position, :parbudget_center_id)
  end

  def load_resource
    @responsible = @model.find(params[:id])
  rescue
    @responsible = nil
  end

  def search(parametrize = {})
    @responsibles = @model.all
    @filters = []

    if !parametrize[:search_responsible].blank?
      @filters.push("#{I18n.t('admin.parbudget.responsible.search_responsible')}: #{parametrize[:search_responsible]}")
      @responsibles = @responsibles.where("translate(UPPER(cast(full_name as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_responsible]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
    end

    if !parametrize[:search_phone].blank?
      @filters.push("#{I18n.t('admin.parbudget.responsible.search_phone')}: #{parametrize[:search_phone]}")
      @responsibles = @responsibles.where("translate(UPPER(cast(phone as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_phone]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
    end

    if !parametrize[:search_email].blank?
      @filters.push("#{I18n.t('admin.parbudget.responsible.search_email')}: #{parametrize[:search_email]}")
      @responsibles = @responsibles.where("translate(UPPER(cast(email as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_email]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
    end

    if !parametrize[:search_position].blank?
      @filters.push("#{I18n.t('admin.parbudget.responsible.search_position')}: #{parametrize[:search_position]}")
      @responsibles = @responsibles.where("translate(UPPER(cast(position as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_position]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
    end

    if !parametrize[:search_center].blank?
      @filters.push("#{I18n.t('admin.parbudget.responsible.search_center')}: #{parametrize[:search_center]}")
      @responsibles = @responsibles.joins(:parbudget_center).where("translate(UPPER(cast(parbudget_centers.denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_center]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
    end
  end
rescue
  @responsibles = []
  @filters = []
end
