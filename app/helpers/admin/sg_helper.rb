module Admin::SgHelper
    require 'json' 


    def get_filter_sg_tab
        [
            {name: I18n.t('admin.sg.tab.search'), type: 'search'},
            {name: I18n.t('admin.sg.tab.order'), type: 'order'}
        ]
    end

    def get_header_tables_fields
        [
            I18n.t('admin.sg.list.table_name'),
            I18n.t('admin.sg.list.field_name')
        ]
    end

    def get_tables
        tables = []
        Dir.glob(Rails.root.join('app/models/*')).each do |x|
            if x.include?(".rb")
                model = "#{x}".gsub(".rb", '').gsub(Rails.root.join('app/models/').to_s, '').singularize.classify.constantize
                begin
                    tables << [model.model_name.human, model.model_name]
                rescue
                end
            end
        end
        
        final = [[I18n.t('admin.sg.form.table_name')+"...", '']]
        final + tables.sort
    rescue
        [[I18n.t('admin.sg.form.table_name')+"...", '']]
    end

    def get_fields_by_table(table_name)
        model = table_name.singularize.classify.constantize
        fields = []
        if !model.try(:column_names).blank?
            model.try(:column_names).each do |field|
                fields << [field,field]
            end
        end

        final = [[I18n.t('admin.sg.form.field_name')+"...", '']]
        final + fields.sort
    rescue
        [[I18n.t('admin.sg.form.field_name')+"...", '']]
    end

    def get_sg_search_types_data
        [
            [I18n.t('admin.sures.searchs_settings.types_data.select'), 'select'],
            [I18n.t('admin.sures.searchs_settings.types_data.order'), 'order'],
            [I18n.t('admin.sures.searchs_settings.types_data.text'), 'text']
        ]
    end

    def get_sg_search_rules
        [
            [I18n.t('admin.sures.searchs_settings.rules.asc'), 'asc'],
            [I18n.t('admin.sures.searchs_settings.rules.desc'), 'desc']
        ]
    end

end