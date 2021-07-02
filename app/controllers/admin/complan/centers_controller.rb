class Admin::Complan::CentersController < Admin::Complan::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_resource
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
      redirect_to admin_complan_centers_path,  notice: I18n.t("admin.complan.center.create_success")
    else
      flash[:error] = I18n.t("admin.complan.center.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.complan.center.create_error")
    redirect_to admin_complan_centers_path
  end

  def update
    if @center.update(center_strong_params)
      audit_update(@center)
      redirect_to admin_complan_centers_path,  notice: I18n.t("admin.complan.center.update_success")
    else
      flash[:error] = I18n.t("admin.complan.center.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.complan.center.update_error")
    redirect_to admin_complan_centers_path    
  end

  def destroy
    id = @center.id
    if @center.destroy
      audit_delete("center", id, "parbudget")
      redirect_to admin_complan_centers_path,  notice: I18n.t("admin.complan.center.destroy_success")
    else
      flash[:error] = I18n.t("admin.complan.center.destroy_error")
      redirect_to admin_complan_centers_path(errors: @center.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.complan.center.destroy_error")
    redirect_to admin_complan_centers_path
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
    @model = ::Complan::Center
  end

  def center_strong_params
    params.require(:complan_center).permit(:denomination, :organism, :address,:dg,:sg,
      :complan_people_attributes=> [:id, :name, :position, :phone, :email, :address,:_destroy])
  end

  def load_resource
    @center = @model.find(params[:id])
  rescue
    @center = nil
  end

  def search(parametrize = {})
    @centers = @model.all
    @filters = []

    begin
      if !parametrize[:search_organism].blank?
        @filters.push("#{I18n.t('admin.complan.center.search_organism')}: #{parametrize[:search_organism]}")
        @centers = @centers.where("translate(UPPER(cast(organism as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_organism]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_denomination].blank?
        @filters.push("#{I18n.t('admin.complan.center.search_denomination')}: #{parametrize[:search_denomination]}")
        @centers = @centers.where("translate(UPPER(cast(denomination as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_denomination]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_address].blank?
        @filters.push("#{I18n.t('admin.complan.center.search_address')}: #{parametrize[:search_address]}")
        @centers = @centers.where("translate(UPPER(cast(address as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_address]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:search_dg].blank?
        @filters.push("#{I18n.t('admin.complan.center.search_dg')}: #{parametrize[:search_dg]}")
        @centers = @centers.where("dg = #{parametrize[:search_dg]}")
      end
    rescue
    end

    begin
      if !parametrize[:search_sg].blank?
        @filters.push("#{I18n.t('admin.complan.center.search_sg')}: #{parametrize[:search_sg]}")
        @centers = @centers.where("dg = #{parametrize[:search_sg]}")
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
