class Admin::Parbudget::ResponsiblesController < Admin::Parbudget::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:new,:create,:edit,:update,:index]
  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]
  def index
    search(params)
    @responsibles = Kaminari.paginate_array(@responsibles).page(params[:page]).per(20)
  end

  def new
    @responsible = @model.new
  end

  def edit
  end

  def create
    @responsible=  @model.new(responsible_strong_params)
    if @responsible.save
      audit_create(@responsible)
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
      audit_update(@responsible)
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
    id = @responsible.id
    if @responsible.destroy
      audit_delete("responsible", id, "parbudget")
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
    @centers = ::Parbudget::Center.all.select(:id, :denomination)
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

    begin
      if !parametrize[:search_responsible].blank?
        @filters.push("#{I18n.t('admin.parbudget.responsible.search_responsible')}: #{parametrize[:search_responsible]}")
        @responsibles = @responsibles.where("translate(UPPER(cast(full_name as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_responsible]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_phone].blank?
        @filters.push("#{I18n.t('admin.parbudget.responsible.search_phone')}: #{parametrize[:search_phone]}")
        @responsibles = @responsibles.where("translate(UPPER(cast(phone as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_phone]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_email].blank?
        @filters.push("#{I18n.t('admin.parbudget.responsible.search_email')}: #{parametrize[:search_email]}")
        @responsibles = @responsibles.where("translate(UPPER(cast(email as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_email]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_position].blank?
        @filters.push("#{I18n.t('admin.parbudget.responsible.search_position')}: #{parametrize[:search_position]}")
        @responsibles = @responsibles.where("translate(UPPER(cast(position as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_position]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_center].blank?
        @filters.push("#{I18n.t('admin.parbudget.responsible.search_center')}: #{parametrize[:search_center]}")
        @responsibles = @responsibles.joins(:parbudget_center).where("translate(UPPER(cast(parbudget_centers.denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_center]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:subnav].blank? && parametrize[:subnav].to_s != "all"
        @filters.push("#{I18n.t('admin.parbudget.responsible.search_center')}: #{parametrize[:subnav]}")
        @responsibles = @responsibles.where(parbudget_center_id: parametrize[:subnav].to_i)
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @responsibles = @responsibles.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @responsibles = @responsibles.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @responsibles = @responsibles.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @responsibles = []
    @filters = []
  end

end
