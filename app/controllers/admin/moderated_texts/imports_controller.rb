class Admin::ModeratedTexts::ImportsController < Admin::ModeratedTexts::BaseController
  load_and_authorize_resource class: "ModeratedTexts::Import"

  def create
    @import = ModeratedTexts::Import.new(moderated_texts_import_params)

    if @import.save
      notice = t("admin.moderated_texts.imports.create.notice")
      redirect_to admin_moderated_texts_path, notice: notice
    else
      render :new
    end
  end

  private

    def moderated_texts_import_params
      return {} unless params[:moderated_texts_import].present?
      params.require(:moderated_texts_import).permit(:file)
    end
end
