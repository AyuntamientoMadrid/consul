class SuresController < SuresBaseController
    include Admin::SuresHelper
    
    before_action :load_districts, only: [:index,:search,:actuation]
    def index
        @cards = Sures::CustomizeCard.body
    end

    def search
        @resultado = ""
        @actuations = []
        @sures_searchs_settings = Sures::SearchSetting.search_settings.order(id: :asc)
        @sures_orders_filter = Sures::SearchSetting.order_settings.order(id: :asc)

        run_search(params)
    end

    def actuation
        @actuation = Sures::Actuation.find_by(id: params[:id])
    end

    private

    def run_search(parametrize)
        aux_active = false

        aux_fields = @sures_searchs_settings.map {|f| f.title.parameterize.underscore.to_s }
        aux_fields.push('search')

        aux_fields.each do |f|
            if !parametrize[f.to_sym].blank?
                aux_active = true
                break
            end
        end

        @search_terms = aux_active
        if aux_active
            @actuations = Sures::Actuation.joins(:translations).all
            @resultado =  @resultado + (@resultado.blank? ? parametrize[:search] : "/#{parametrize[:search]}")
            if !parametrize[:search].blank?
                @actuations = @actuations.where("translate(UPPER(cast(proposal_title as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(proposal_objective as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(territorial_scope as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(location_performance as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(technical_visibility as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(actions_taken as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(other as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU') OR
                    translate(UPPER(cast(tracking as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU')",
                    "%#{parametrize[:search]}%", "%#{parametrize[:search]}%", "%#{parametrize[:search]}%",
                    "%#{parametrize[:search]}%", "%#{parametrize[:search]}%", "%#{parametrize[:search]}%",
                    "%#{parametrize[:search]}%", "%#{parametrize[:search]}%"
                )
            end
            
            if !parametrize[:show_fields].blank? && parametrize[:show_fields].to_s != "true"
                aux_fields.each do |f|
                    if !parametrize[f.to_sym].blank? && f.to_s != "search"
                        aux_field_search = @sures_searchs_settings.select {|x| x.title.parameterize.underscore.to_s == f.to_s }[0]
                        if !aux_field_search.blank?

                            parse_data_json(aux_field_search.data).each do |k,v|
                                if v.to_s == parametrize[f.to_sym].to_s
                                    @resultado =  @resultado + (@resultado.blank? ? k.to_s : "/#{k.to_s}")
                                    break
                                end
                            end
                            
                            @actuations = @actuations.where("translate(UPPER(cast(#{aux_field_search.field} as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast(? as varchar)), 'ÁÉÍÓÚ', 'AEIOU')", "%#{parametrize[f.to_sym]}%")
                        end
                    end
                end
            end

            if !parametrize[:distrito].blank? && !parametrize[:distrito].to_s.include?('23')
                @actuations = Sures::Actuation.joins(:translations).all if @actuations.blank?
                actuations_geozones = []
                @actuations.each do |a|
                    if parametrize[:distrito].size == 1
                        actuations_geozones << a.id if a.geozones.include?(parametrize[:distrito][0])
                    else
                        parametrize[:distrito].map {|z| actuations_geozones << a.id if a.geozones.include?(z)}
                    end
                end
                @actuations = @actuations.where("sures_actuations.id IN (?)", actuations_geozones)
            end

            #@actuations = @actuations.where("project like '%#{parametrize[:proyecto]}%'") if !parametrize[:proyecto].blank?

            aux_order = "updated_at desc"
            if  @sures_orders_filter.blank?
                @type = ""
            elsif !params[:type].blank?
                aux = @sures_orders_filter.select {|order| order.title.parameterize.underscore == params[:type] }.first
                aux_order = "#{aux.field} #{aux.rules.split(';').length > 1 ? aux.rules.split(';')[1] : aux.rules }"
                @type = params[:type]
            else
                aux = @sures_orders_filter.select {|order| order.rules.to_s.include?('default') }.first
                if aux.blank?
                    aux = @sures_orders_filter.first
                end
                aux_order = "#{aux.field} #{aux.rules.split(';').length > 1 ? aux.rules.split(';')[1] : aux.rules }"
                @type = aux.title.parameterize.underscore
            end
            @actuations = @actuations.order(aux_order)
            paginate = 50
            if !Setting.find_by(key: 'actuations_pagination_limit').value.blank? && Setting.find_by(key: 'actuations_pagination_limit').value.to_i != 0
                paginate = Setting.find_by(key: 'actuations_pagination_limit').value.to_i
            end

            @actuations = @actuations.page(params[:page]).per(paginate)
        end
    end

    def load_districts
        @districts = {}
        disabled = []
        data = Sures::SearchSetting.find_by(title: "Distrito").data
        data_status = Sures::SearchSetting.find_by(title: "Distrito").data_status
        parse_data_json(data_status).map {|k,v| disabled << k.to_s if v == false}
        parse_data_json(data).map {|k,v| @districts = @districts.merge!({k.to_s == "Toda la ciudad" ? "SURES(TODOS)" : k=>v}) if disabled.include?(v.to_s) == false}
        @districts
    end
end