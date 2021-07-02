class Admin::Parbudget::TopicsController < Admin::Parbudget::BaseController
  include Admin::AuditHelper
  respond_to :html, :js, :csv
  before_action :load_resource, only: [:update_topic,:destroy]
  before_action :authenticate_editor, only: [:index, :generate_topic, :destroy, :update_topic]
  before_action :authenticate_editor, only: [:generate_topic, :update_topic, :destroy]
  
  def index
    search(params)
    @topics = Kaminari.paginate_array(@topics).page(params[:page]).per(20)
  end

  def generate_topic
    topic=  @model.new
    if topic.save(validate: false)
      audit_create(topic)
      redirect_to admin_parbudget_topics_path,  notice: I18n.t("admin.parbudget.topic.create_success")
    else
      flash[:error] =I18n.t("admin.parbudget.topic.create_error")
      redirect_to admin_parbudget_topics_path(errors: topic.errors.full_messages)
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.topic.create_error")
    redirect_to admin_parbudget_topics_path
  end

  def update_topic
    if @topic.update(topic_strong_params)
      audit_update(@topic)
      redirect_to admin_parbudget_topics_path,  notice: I18n.t("admin.parbudget.topic.update_success")
    else
      flash[:error] = I18n.t("admin.parbudget.topic.update_error")
      redirect_to admin_parbudget_topics_path(errors: @topic.errors.full_messages, id: @topic.id)
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.topic.update_error")
    redirect_to admin_parbudget_topics_path    
  end

  def destroy
    id = @topic.id
    if @topic.destroy
      audit_delete("topic", id, "parbudget")
      redirect_to admin_parbudget_topics_path,  notice: I18n.t("admin.parbudget.topic.destroy_success")
    else
      flash[:error] = I18n.t("admin.parbudget.topic.destroy_error")
      redirect_to admin_parbudget_topics_path(errors: @topic.errors.full_messages, id: @topic.id)
    end
  rescue
    flash[:error] = I18n.t("admin.parbudget.topic.destroy_error")
    redirect_to admin_parbudget_topics_path
  end

  private 

  def get_model
    @model = ::Parbudget::Topic
  end

  def topic_strong_params
    params.require(:parbudget_topic).permit(:name)
  end

  def load_resource
    @topic = ::Parbudget::Topic.find(params[:id])
  rescue
    @topic = nil
  end

  def search(parametrize = {})
    @topics = @model.all
    @filters = []

    begin
      if !parametrize[:search_topic].blank?
        @filters.push("#{I18n.t('admin.parbudget.topic.search_topic')}: #{parametrize[:search_topic]}")
        @topics = @topics.where("translate(UPPER(cast(name as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:search_topic]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
      end
    rescue
    end

    begin
      if !parametrize[:sort_by].blank?
        if parametrize[:direction].blank? || parametrize[:direction].to_s == "asc"
          @topics = @topics.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }
        else
          @topics = @topics.sort_by { |a| a.try(parametrize[:sort_by].to_sym) }.reverse
        end
      else
        @topics = @topics.sort_by { |a| a.try(@model.get_columns[0].to_sym) }
      end
    rescue
    end
  rescue
    @topics = []
    @filters = []
  end

end
