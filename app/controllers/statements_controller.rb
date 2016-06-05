class StatementsController < ApplicationController

  skip_authorization_check

  def new
    @audit = Audit.find(params[:audit_id])
    @statement = @audit.statements.new
  end

  def create
    @audit = Audit.find(params[:audit_id])
    @statement = @audit.statements.new(statement_params)
    if @statement.save
      Mailer.debt_audit_document(path, filename, title, body).deliver_later
      redirect_to "/citizen_audit_welcome", notice: t("flash.actions.create.statement.")
    end
  end

  def show
    @statement = Statement.find(params[:id])
  end

  private

    def statement_params
      params.require(:statement).permit(:title, :body, :attachment)
    end

    def path
      if statement_params[:attachment].present?
        File.absolute_path(params[:statement][:attachment].tempfile)
      end
    end

    def filename
      if statement_params[:attachment].present?
        params[:statement][:attachment].original_filename
      end
    end

    def title
      statement_params[:title]
    end

    def body
      statement_params[:body]
    end

end