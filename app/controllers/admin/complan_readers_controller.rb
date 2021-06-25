class Admin::ComplanReadersController < Admin::BaseController
    load_and_authorize_resource
    has_filters %w[users superadministrators administrators sures_administrators section_administrators 
    organizations officials moderators valuators managers consultants editors parbudget_editors parbudget_readers complan_editors complan_readers]
  
    def index
      @complan_readers = Complan::Reader.all.page(params[:page])
    end
      
    def destroy
      if !@complan_readers.blank?
        if !current_user.blank? && current_user.id == @complan_readers.user_id
          flash[:error] = I18n.t("admin.complan_readers.administrator.restricted_removal")
        else
          user = User.find(@complan_readers.user_id)
          user.profiles_id = nil
          user.save
          @complan_readers.destroy
        end
      else
        flash[:error] = I18n.t("admin.complan_readers.administrator.restricted_removal")
      end

      redirect_to admin_complan_readers_path
    rescue
      flash[:error] = I18n.t("admin.complan_readers.administrator.restricted_removal")
      redirect_to admin_complan_readers_path
    end
  end