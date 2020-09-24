class Admin::Legislation::QuestionsController < Admin::Legislation::BaseController
  include Translatable

  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :question, class: "Legislation::Question", through: :process

  def index
    @questions = @process.questions
  end

  def new
  end

  def other_answers
    @question = Legislation::Question.find(params[:question])
    @answers = Legislation::Answer.where(legislation_question_id: params[:question], legislation_question_option_id: params[:option])
    #render :other_answers
  end

  def create
    @question.author = current_user
    @question.multiple_answers = 1 if question_params[:multiple_answers].blank?
    if @question.save
      notice = t("admin.legislation.questions.create.notice", link: question_path)
      redirect_to admin_legislation_process_questions_path, notice: notice
    else
      flash.now[:error] = t("admin.legislation.questions.create.error")
      render :new
    end
  end

  def update
    if @question.update(question_params)
      notice = t("admin.legislation.questions.update.notice", link: question_path)
      redirect_to edit_admin_legislation_process_question_path(@process, @question), notice: notice
    else
      flash.now[:error] = t("admin.legislation.questions.update.error")
      render :edit
    end
  end

  def destroy
    @question.destroy
    notice = t("admin.legislation.questions.destroy.notice")
    redirect_to admin_legislation_process_questions_path, notice: notice
  end

  private

    def question_path
      legislation_process_question_path(@process, @question).html_safe
    end

    def question_params
      params.require(:legislation_question).permit(
        translation_params(::Legislation::Question), :is_range,
        :multiple_answers, question_options_attributes: [:id, :_destroy, :is_range,
                                      translation_params(::Legislation::QuestionOption)]
      )
    end

    def resource
      @question || ::Legislation::Question.find(params[:id])
    end
end
