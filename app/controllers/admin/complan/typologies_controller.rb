class Admin::Complan::TypologiesController < Admin::Complan::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv
  before_action :load_resource, only: [:update_typology,:destroy]
  load_and_authorize_resource :typology, class: "Complan::Typology"
  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]
  
  def index
    search(params)
    @typologies = Kaminari.paginate_array(@typologies).page(params[:page]).per(20)
  end
  
  def create_typology
    @typology=  @model.new
    if @typology.save(validate: false)
      audit_create(@typology)
      redirect_to admin_complan_typologies_path,  notice: I18n.t("admin.complan.typology.create_success")
    else
      flash[:error] = I18n.t("admin.complan.typology.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.complan.typology.create_error")
    redirect_to admin_complan_typologies_path
  end

  def update_typology
    if @typology.update(typology_strong_params)
      audit_update(@typology)
      redirect_to admin_complan_typologies_path,  notice: I18n.t("admin.complan.typology.update_success")
    else
      flash[:error] = I18n.t("admin.complan.typology.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.complan.typology.update_error")
    redirect_to admin_complan_typologies_path    
  end

  def destroy
    id = @typology.id
    if @typology.destroy
      audit_delete("typology", id, "parbudget")
      redirect_to admin_complan_typologies_path,  notice: I18n.t("admin.complan.typology.destroy_success")
    else
      flash[:error] = I18n.t("admin.complan.typology.destroy_error")
      redirect_to admin_complan_typologies_path(errors: @typology.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.complan.typology.destroy_error")
    redirect_to admin_complan_typologies_path
  end

  private 

  def get_model
    @model = ::Complan::Typology
  end

  def typology_strong_params
    params.require(:complan_typology).permit(:name)
  end

  def load_resource
    @typology = @model.find(params[:id])
  rescue
    @typology = nil
  end

  def search(parametrize = {})
    @typologies = @model.all
    @filters = []

    begin
      if !parametrize[:search_name].blank?
        @filters.push("#{I18n.t('admin.complan.typology.search_name')}: #{parametrize[:search_name]}")
        @typologies = @typologies.where("translate(UPPER(cast(name as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_name]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @typologies = @typologies.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @typologies = @typologies.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @typologies = @typologies.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @typologies = []
    @filters = []
  end
end
