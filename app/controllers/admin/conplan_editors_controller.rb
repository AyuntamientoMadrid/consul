class Admin::ConplanEditorsController < Admin::BaseController
    load_and_authorize_resource
    has_filters %w[users superadministrators administrators sures_administrators section_administrators 
    organizations officials moderators valuators managers consultants editors parbudget_editors parbudget_readers conplan_editors conplan_readers]
  
    def index
      @conplan_editors = @conplan_editors.page(params[:page])
    end
  
    def search
      @users = User.search(params[:name_or_email])
                   .includes(:conplan_editors)
                   .page(params[:page])
                   .for_render
    end
  
    def create
      @conplan_editors.user_id = params[:user_id]
      @conplan_editors.save
  
      redirect_to admin_conplan_editors_path
    end
  
    def destroy
        if !@conplan_editors.blank?
          if !current_user.blank? && current_user.id == @conplan_editors.user_id
            flash[:error] = I18n.t("admin.conplan_editors.administrator.restricted_removal")
          else
            user = User.find(@conplan_editors.user_id)
            user.profiles_id = nil
            user.save
            @conplan_editors.destroy
          end
        else
          flash[:error] = I18n.t("admin.conplan_editors.administrator.restricted_removal")
        end
  
        redirect_to admin_conplan_editors_path
    rescue
      flash[:error] = I18n.t("admin.conplan_editors.administrator.restricted_removal")
      redirect_to admin_conplan_editors_path
    end
  end