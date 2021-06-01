class WelcomeController < ApplicationController
  respond_to :html, :js
  skip_authorization_check
  before_action :set_user_recommendations, only: :index, if: :current_user
  before_action :authenticate_user!, only: :welcome
  before_action :get_key_youtube, only: [:encuentrosconexpertos, :eventos, :agend_admin]

 

  layout "devise", only: [:welcome, :verification]

  def index
    @header = Widget::Card.header.first
    @feeds = Widget::Feed.active
    @cards = Widget::Card.body
    @banners = Banner.in_section("homepage").with_active
  end

  def welcome
    if current_user.level_three_verified?
      redirect_to page_path("welcome_level_three_verified")
    elsif current_user.level_two_or_three_verified?
      redirect_to page_path("welcome_level_two_verified")
    else
      redirect_to page_path("welcome_not_verified")
    end
  end

  def verification
    redirect_to verification_path if signed_in?
  end

  def encuentrosconexpertos
    begin
      @videoId = Setting.find_by(key: "youtube_connect").value
    rescue
      @videoId = ""
    end
    begin
      @playlistId = Setting.find_by(key: "youtube_playlist_connect").value
    rescue
      @playlistId = ""
    end
  end

  def eventos
    begin
      @videoId = Setting.find_by(key: "eventos_youtube_connect").value
    rescue
      @videoId = ""
    end
    begin
      @playlistId = Setting.find_by(key: "eventos_youtube_playlist_connect").value
    rescue
      @playlistId = ""
    end
  end

  def agend_admin
    begin
      @videoId =  Setting.find_by(key: "agend_youtube_connect").value
    rescue
      @videoId = ""
    end
    begin 
      @playlistId = Setting.find_by(key: "agend_youtube_playlist_connect").value
    rescue
      @playlistId = ""
    end
    @event_agends = EventAgend.all.order(date_at: :asc).group_by(&:date_at)
  rescue
    @videoId = ""
    @playlistId = ""
    @event_agends = nil
  end

  def generic_search
    @orders_settings = Sg::Setting.order_settings.active.order(id: :asc)
    @search_settings = Sg::Setting.search_settings.active.order(id: :asc)
    @search_generic = Sg::Generic.search_type.first
    @order_generic = Sg::Generic.order_type.first
    get_parametrizer_list(params)
    get_orders(params)
  rescue
    @orders_settings = []
    @search_settings = []
    @search_generic = nil
    @order_generic = nil
    @search_terms = false
    @resultado = []
    @listados = []
  end


  private

  def get_key_youtube
    @key = Rails.application.secrets.yt_api_key
    @key_x = Rails.application.secrets.yt_api_key_x
    @embed_domain = Rails.application.secrets.embed_domain
  rescue
    @key= ""
    @key_x=""
    @embed_domain = ""
  end

 
  def set_user_recommendations
    @recommended_debates = Debate.recommendations(current_user).sort_by_recommendations.limit(3)
    @recommended_proposals = Proposal.recommendations(current_user).sort_by_recommendations.limit(3)
  end

  def get_parametrizer_list(parametrize)
    @search_terms = false
    @resultado = []
    @listados = []
    sg_orders = @order_generic.try(:sg_table_orders)
    search_data_aux_gen = []

    # Se mapean los titulos a simbolos parametrizables y se añade el buscador genérico #
    aux_fields = @generic_searchs_settings.map {|f| f.title.parameterize.underscore.to_s }
    aux_fields.push('search')

    # Recorremos el listado mapeado #
    aux_fields.each do |f|
      #Comprobamos si existe el campo #
      if !parametrize[f.to_sym].blank?
        # Si existe con datos indicamos que hay datos de búsqueda #
        @search_terms = true

        #Cargamos el dato de preferencia generico (search) o avanzado (el resto) #
        search_aux = f.to_s=="search" ? @search_generic : @search_settings.select {|x| x.title.parameterize.underscore.to_s == f.to_s }[0]
        
        # Precarga de listados a usar tanto en la obtención de resultados como en el filtrado #
        sg_selects = search_aux.try(:sg_selects)
        sg_tables = search_aux.try(:sg_table_fields)
        

        if !sg_tables.blank?
          sg_tables.each do |t| 
            model = t.table_name.singularize.classify.constantize
            list = @listados.select {|l| l[:model].model_name.to_s == model.model_name.to_s}
            model_list = !@listados.blank? && !list.blank? ? list[0][:list_base] : ""
            translate = false
            translate = true if !model.try(:translate_column_names).blank? && model.try(:translate_column_names).include?(t.field_name.to_sym)
            value = ActionController::Base.helpers.sanitize(parametrize[f.to_sym])
            model_list = model_list + "#{" OR " if !model_list.blank?} translate(UPPER(cast(#{translate ? "#{model.table_name.singularize}_translations" : model.table_name }.#{t.field_name} as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{value}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')"
            
            if list.blank?
              order = 0
              sg_orders.each do |o|
                if o.table_name.to_s== model.model_name.to_s
                  order = o.order
                  break
                end
              end
              
              @listados.push({model: model, table_field: [t.field_name], list_base: model_list, list: nil, order: order})
            elsif !@listados.select {|l| l[:model].model_name.to_s == model.model_name.to_s}.blank?
              @listados.select {|l| l[:model].model_name.to_s == model.model_name.to_s}[0][:list_base] = model_list
              @listados.select {|l| l[:model].model_name.to_s == model.model_name.to_s}[0][:table_field].push(t.field_name)
            end
          end
        end
        
        search_data_aux = parametrize[f.to_sym]
        if !search_aux.try(:data_type).blank? 
          case search_aux.try(:data_type).to_s
          when "select"
            search_data_aux = sg_selects.select {|x| x.value.to_s == parametrize[f.to_sym].to_s }[0].try(:key)
          when "checkbox"
            search_data_aux = parametrize[f.to_sym].to_s == "true" ? "Sí" : "No"
          end
        end 

        search_data_aux_gen.push({search: search_data_aux, field: (f.to_s=="search" ? "Barra de búsqueda general" : search_aux.try(:title))})
      end
    end

    if !@listados.blank?
      @listados = @listados.sort_by {|l| l[:order]} 
      @listados.each do |l|
        if l[:model].try(:translate_column_names).blank?
          l[:list] = l[:model].where(l[:list_base])
        else
          l[:list] = l[:model].joins(:translations).where(l[:list_base])
        end

        if l[:model].try(:model_name).to_s == "Legislation::Process"
          l[:list]= l[:list].seached.published.not_in_draft
        elsif l[:model].try(:model_name).to_s == "Proposal"
          l[:list]= l[:list].published
        end
        set_votable(l)
        @resultado.push({tabla: l[:model].model_name.human, search: search_data_aux_gen, count: l[:list].blank? ? 0 : l[:list].count})  
        l[:list] = l[:list].page(parametrize[:"page_#{l[:model].model_name.to_s.parameterize.underscore}"]).per(5)         
      end
    end
  end

  def get_orders(parametrize)
    return if parametrize[:type_order].blank? || parametrize[:type_order].to_s == "all"
    aux_resultado = []
    aux_listados = []

    @orders_settings.each do |order|
      if order.title.to_s.parameterize.underscore == parametrize[:type_order].to_s.parameterize.underscore
        table_fields = order.try(:sg_table_fields)
        table_fields.each do |t| 
          exist = @listados.select {|l| l[:model].model_name.to_s == t.table_name.to_s}[0]
          resultado = @resultado.select {|l| l[:tabla].to_s == t.table_name.singularize.classify.constantize.model_name.human.to_s}[0]

          if !exist.blank?
            if order.data_type.to_s == "asc"
              exist[:list] = exist[:list].order("#{t.field_name} ASC")
            else
              exist[:list] = exist[:list].order("#{t.field_name} DESC")
            end
            aux_listados.push(exist)
            aux_resultado.push(resultado)
          end
        end
      end
    end

    @listados = aux_listados
    @resultado = aux_resultado
  end

  def set_votable(lista)
    begin
      set_debate_votes(lista[:list])
    rescue
    end
    begin
      set_proposal_votes(lista[:list])
    rescue
    end
    begin
      set_topic_votes(lista[:list])
    rescue
    end   
    begin
      @legislation_proposal_votes = current_user ? current_user.legislation_proposal_votes(lista[:list]) : {}
    rescue      
    end  
    begin
      load_investment_votes(lista[:list])
      @investment_ids =lista[:list].pluck(:id)     
    rescue
    end        
  end
end
