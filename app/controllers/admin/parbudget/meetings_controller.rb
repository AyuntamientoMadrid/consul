class Admin::Parbudget::MeetingsController < Admin::Parbudget::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv, :pdf
  before_action :load_data, only: [:index]
  before_action :authenticate_editor, only: [:new, :create, :edit, :update, :destroy]
  def index
    search(params)
    @meetings = Kaminari.paginate_array(@meetings).page(params[:page]).per(20)
  end

  def new
    @meeting = @model.new
  end

  def edit
  end

  def create
    @meeting=  @model.new(meeting_strong_params)
    if @meeting.save
      audit_create(@meeting)
      redirect_to admin_parbudget_meetings_path,  notice: I18n.t("admin.parbudget.meeting.create_success")
    else
      flash[:error] = I18n.t("admin.parbudget.meeting.create_error")
      render :new
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.meeting.create_error")
    redirect_to admin_parbudget_meetings_path
  end

  def update
    if @meeting.update(meeting_strong_params)
      audit_update(@meeting)
      redirect_to admin_parbudget_meetings_path,  notice: I18n.t("admin.parbudget.meeting.update_success")
    else
      flash[:error] = I18n.t("admin.parbudget.meeting.update_error")
      render :edit
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.meeting.update_error")
    redirect_to admin_parbudget_meetings_path    
  end

  def destroy
    id = @meeting.id
    if @meeting.destroy
      audit_delete("meeting", id, "parbudget")
      redirect_to admin_parbudget_meetings_path,  notice: I18n.t("admin.parbudget.meeting.destroy_success")
    else
      flash[:error] = I18n.t("admin.parbudget.meeting.destroy_error")
      redirect_to admin_parbudget_meetings_path(errors: @meeting.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.meeting.destroy_error")
    redirect_to admin_parbudget_meetings_path
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        
        render pdf: "#{@meeting.who_requests}_#{@meeting.date_at_convert}",
        layout: 'pdf.html',
        page_size: 'A4',
        encoding: "UTF-8"
       
      end
    end
  end

  private 

  def get_model
    @model = ::Parbudget::Meeting
  end

  def load_data
    @subnav = [{title: "Todos",value: "all"}, {title: "Pendientes (#{@model.pending.count})",value: "pending"},{title: "Realizadas",value: "done"}]
  end

  def meeting_strong_params
    params.require(:parbudget_meeting).permit(:reason, :date_at, :who_requests, {parbudget_assistants_attributes: [:id, :full_name, :_destroy]})
  end

  def load_resource
    @meeting = @model.find(params[:id])
  rescue
    @meeting = nil
  end

  def search(parametrize = {})
    @meetings = @model.all
    @filters = []

    begin
      if !params[:subnav].blank? && params[:subnav].to_s != "all"
        case params[:subnav].to_s
        when "pending"
          @meetings = @meetings.pending
        when "done"
          @meetings = @meetings.done
        end
      end
    rescue
    end

    begin
      if !parametrize[:search_date_start].blank? && !parametrize[:search_date_end].blank?
        @filters.push("#{I18n.t('admin.parbudget.meeting.search_date_start')}: #{parametrize[:search_date_start]}")
        @filters.push("#{I18n.t('admin.parbudget.meeting.search_date_end')}: #{parametrize[:search_date_end]}")
        @meetings = @meetings.where("date_at BETWEEN to_date(?, 'YYYY-MM-DD') AND to_date(?, 'YYYY-MM-DD')", parametrize[:search_date_start], parametrize[:search_date_end])
      elsif !parametrize[:search_date_start].blank?
        @filters.push("#{I18n.t('admin.parbudget.meeting.search_date_start')}: #{parametrize[:search_date_start]}")
        @meetings = @meetings.where("date_at >= to_date(?, 'YYYY-MM-DD') ", parametrize[:search_date_start])
      elsif !parametrize[:search_date_end].blank?
        @filters.push("#{I18n.t('admin.parbudget.meeting.search_date_end')}: #{parametrize[:search_date_end]}")
        @meetings = @meetings.where("date_at <= to_date(?, 'YYYY-MM-DD') ", parametrize[:search_date_end])
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @meetings = @meetings.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @meetings = @meetings.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @meetings = @meetings.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @meetings = []
    @filters = []
  end
end
