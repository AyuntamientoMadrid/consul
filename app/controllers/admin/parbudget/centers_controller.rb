class Admin::Parbudget::CentersController < Admin::Parbudget::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:index]
  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]

  def index
    search(params)
    @centers = Kaminari.paginate_array(@centers).page(params[:page]).per(20)
  end

  def new
    @center = @model.new
  end

  def edit
  end

  def create
    @center=  @model.new(center_strong_params)
    if @center.save
      audit_create(@center)
      redirect_to admin_parbudget_centers_path,  notice: I18n.t("admin.parbudget.center.create_success")
    else
      flash[:error] = I18n.t("admin.parbudget.center.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.center.create_error")
    redirect_to admin_parbudget_centers_path
  end

  def update
    if @center.update(center_strong_params)
      audit_update(@center)
      redirect_to admin_parbudget_centers_path,  notice: I18n.t("admin.parbudget.center.update_success")
    else
      flash[:error] = I18n.t("admin.parbudget.center.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.center.update_error")
    redirect_to admin_parbudget_centers_path    
  end

  def destroy
    id = @center.id
    if @center.destroy
      audit_delete("center", id, "parbudget")
      redirect_to admin_parbudget_centers_path,  notice: I18n.t("admin.parbudget.center.destroy_success")
    else
      flash[:error] = I18n.t("admin.parbudget.center.destroy_error")
      redirect_to admin_parbudget_centers_path(errors: @center.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.center.destroy_error")
    redirect_to admin_parbudget_centers_path
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @center.denomination,
        layout: 'pdf.html',
        page_size: 'A4',
        encoding: "UTF-8"
      end
    end
  end

  private 

  def get_model
    @model = ::Parbudget::Center
  end

  def center_strong_params
    params.require(:parbudget_center).permit(:denomination, :code, :code_section, :code_program, :responsible,
      :government_area, :general_direction, :parbudget_project_id,
      {:parbudget_responsibles_attributes => [:parbudget_center_id, :full_name, :email, :phone, :position, :_destroy]})
  end


  def load_resource
    @center = @model.find(params[:id])
  rescue
    @center = nil
  end

  def load_data
    @responsibles = ::Parbudget::Responsible.all.order(full_name: :asc).select(:full_name, :id)
    @projects = ::Parbudget::Project.all.order(denomination: :asc).select(:denomination, :id)
  end

  def search(parametrize = {})
    @centers = @model.all
    @filters = []

    begin
      if !parametrize[:search_center_code].blank?
        @filters.push("#{I18n.t('admin.parbudget.center.search_center_code')}: #{parametrize[:search_center_code]}")
        @centers = @centers.where("translate(UPPER(cast(code as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_center_code]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_section_code].blank?
        @filters.push("#{I18n.t('admin.parbudget.center.search_section_code')}: #{parametrize[:search_section_code]}")
        @centers = @centers.where("translate(UPPER(cast(code_section as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_section_code]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_program_code].blank?
        @filters.push("#{I18n.t('admin.parbudget.center.search_program_code')}: #{parametrize[:search_program_code]}")
        @centers = @centers.where("translate(UPPER(cast(code_program as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_program_code]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_denomination].blank?
        @filters.push("#{I18n.t('admin.parbudget.center.search_denomination')}: #{parametrize[:search_denomination]}")
        @centers = @centers.where("translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_denomination]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_responsible].blank?
        @filters.push("#{I18n.t('admin.parbudget.center.search_responsible')}: #{parametrize[:search_responsible]}")
        @centers = @centers.where("translate(UPPER(cast(responsible as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_responsible]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR id in (?)", 
          ::Parbudget::Responsible.where(id: parametrize[:search_responsible]).select(:parbudget_center_id)
      )
      end
    rescue
    end

    begin
      if !parametrize[:search_project].blank?
        @filters.push("#{I18n.t('admin.parbudget.center.search_project')}: #{parametrize[:search_project]}")
        @centers = @centers.where("parbudget_project_id =  ?",parametrize[:search_project])
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @centers = @centers.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @centers = @centers.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @centers = @centers.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @centers = []
    @filters = []
  end
end
