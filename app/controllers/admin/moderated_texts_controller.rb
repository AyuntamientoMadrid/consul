class Admin::ModeratedTextsController < Admin::BaseController
  before_action :load_word, only: [:destroy, :edit, :update]

  load_and_authorize_resource class: "ModeratedText"

  def index
    @words = ModeratedText.all.page(params[:page])
    @occurrence_count = ::ModeratedContent.occurrence_count
  end

  def new
    @word = ModeratedText.new
  end

  def create
    @word = ModeratedText.new(moderated_text_params)

    if @word.save
      notice = t("admin.moderated_texts.create.notice")
      redirect_to admin_moderated_texts_path, notice: notice
    else
      render :new
    end
  end

  def edit; end

  def update
    if @word.update(moderated_text_params)
      notice = t("admin.moderated_texts.update.notice")
      redirect_to admin_moderated_texts_path, notice: notice
    else
      flash.now[:error] = t("admin.moderated_texts.update.error")
      render :edit
    end
  end

  def destroy
    @word.destroy
    redirect_to admin_moderated_texts_path, notice: t("admin.moderated_texts.destroy.notice")
  end

  private

    def moderated_text_params
      params.require(:moderated_text).permit(:text)
    end

    def load_word
      @word = ModeratedText.find(params[:id])
    end
end
