class Admin::ParbudgetReadersController < Admin::BaseController
    load_and_authorize_resource
    has_filters %w[users superadministrators administrators sures_administrators section_administrators 
      organizations officials moderators valuators managers consultants editors parbudget_editors parbudget_readers complan_editors complan_readers]
  
    def index
      @parbudget_readers = Parbudget::Reader.all.page(params[:page])
    end
  
    def search
      @users = User.search(params[:name_or_email])
                   .includes(:parbudget_readers)
                   .page(params[:page])
                   .for_render
    end
  
    def create
      @parbudget_readers.user_id = params[:user_id]
      @parbudget_readers.save
  
      redirect_to admin_parbudget_readers_path
    end
  
    def destroy
        if !@parbudget_readers.blank?
          if !current_user.blank? && current_user.id == @parbudget_readers.user_id
            flash[:error] = I18n.t("admin.parbudget_readers.administrator.restricted_removal")
          else
            user = User.find(@parbudget_readers.user_id)
            user.profiles_id = nil
            user.save
            @parbudget_readers.destroy
          end
        else
          flash[:error] = I18n.t("admin.parbudget_readers.administrator.restricted_removal")
        end
  
        redirect_to admin_parbudget_readers_path
    rescue
      flash[:error] = I18n.t("admin.parbudget_readers.administrator.restricted_removal")
      redirect_to admin_parbudget_readers_path
    end
  end