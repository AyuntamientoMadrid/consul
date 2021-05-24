module Admin::SuresHelper
    require 'json' 
    def get_list_sures_status  
        aux = {}
        #["study", "tramit", "process", "fhinish" ].each {|x| aux.merge!({:"#{I18n.t("admin.sures.actuations.actuation.status_#{x}")}" => x}) }
        disabled = []
        data = Sures::SearchSetting.find_by(title: "Estado de ejecución de la actuación").data
        data_status = Sures::SearchSetting.find_by(title: "Estado de ejecución de la actuación").data_status
        
        parse_data_json(data_status).map {|k,v| disabled << k.to_s if v == false}
        parse_data_json(data).map {|k,v| aux = aux.merge!({k=>v}) if disabled.include?(v.to_s) == false}
        aux
    end

    def get_list_sures_financing   
        aux = {}
        #["planed", "tramit", "ifs", "other" ].each {|x| aux.merge!({:"#{I18n.t("admin.sures.actuations.actuation.financing_#{x}")}" => x}) }
        disabled = []
        data = Sures::SearchSetting.find_by(title: "Estratégia").data
        data_status = Sures::SearchSetting.find_by(title: "Estratégia").data_status
        
        parse_data_json(data_status).map {|k,v| disabled << k.to_s if v == false}
        parse_data_json(data).map {|k,v| aux = aux.merge!({k=>v}) if disabled.include?(v.to_s) == false}
        aux 
    end


    def parse_data_json(data)
        eval(JSON.parse(data.to_s)).to_h
    rescue
        eval(data)
    end


    def get_filter_sures_search_tab
        [
            {name: I18n.t('admin.sures.searchs_settings.filter.search'), type: 'search'},
            {name: I18n.t('admin.sures.searchs_settings.filter.order'), type: 'order'}
        ]
    end

    def get_sures_search_types_data
        [
            [I18n.t('admin.sures.searchs_settings.types_data.select'), 'select'],
            [I18n.t('admin.sures.searchs_settings.types_data.order'), 'order'],
            [I18n.t('admin.sures.searchs_settings.types_data.text'), 'text'],
            [I18n.t('admin.sures.searchs_settings.types_data.fulltext'), 'fulltext']
        ]
    end

    def get_sures_search_rules
        [
            [I18n.t('admin.sures.searchs_settings.rules.default_asc'), 'default;asc'],
            [I18n.t('admin.sures.searchs_settings.rules.default_desc'), 'default;desc'],
            [I18n.t('admin.sures.searchs_settings.rules.asc'), 'asc'],
            [I18n.t('admin.sures.searchs_settings.rules.desc'), 'desc']
        ]
    end
end