class Admin::Complan::AuditsController < Admin::Complan::BaseController
    skip_before_filter :get_model
    load_and_authorize_resource :audit, class: "Audit"

    has_filters %w{all performances centers stategies financings technical_tables projects typologies}

    def index
        search(params)
        @audits = Kaminari.paginate_array(@audits).page(params[:page]).per(20)
    end

    private

    def search(parametrize = {})
        @audits = Audit.all.where(audit_type: "complan")
        @filters = []

        begin
            if !parametrize[:filter].blank? && parametrize[:filter].to_s != 'all'
                @audits = @audits.where(resource: parametrize[:filter].to_s)
            end
        rescue
        end

        begin
            if !parametrize[:operation].blank?
                @filters.push("#{I18n.t('admin.complan.audit.operation')}: #{parametrize[:operation]}")
                @audits = @audits.where("translate(UPPER(cast(action as varchar)), 'ÁÉÍÓÚ', 'AEIOU') LIKE translate(UPPER(cast('%#{parametrize[:operation]}%' as varchar)), 'ÁÉÍÓÚ', 'AEIOU')")
            end
        rescue
        end

        begin
            if !parametrize[:autor].blank?
                @filters.push("#{I18n.t('admin.complan.audit.autor')}: #{parametrize[:autor]}")
                ids = []
                @audits.each { |a| ids << a.user_id }
                @audits = @audits.joins(:user).where("users.username LIKE '%#{parametrize[:autor]}%' AND users.id IN (?)", ids)
            end
        rescue
        end

        begin
            if params[:date_from].present? && params[:date_to].present?
                @filters.push("#{I18n.t('admin.complan.audit.date_from')}: #{parametrize[:date_from]}", "#{I18n.t('admin.complan.audit.date_to')}: #{parametrize[:date_to]}")
                @audits = @audits.where("audits.created_at BETWEEN ? AND ?", Date.parse(params[:date_from]), Date.parse(params[:date_to]))
            elsif params[:date_from].present?
                @filters.push("#{I18n.t('admin.complan.audit.date_from')}: #{parametrize[:date_from]}")
                @audits = @audits.where("audits.created_at >= ? ", Date.parse(params[:date_from]))
            elsif params[:date_to].present?
                @filters.push("#{I18n.t('admin.complan.audit.date_to')}: #{parametrize[:date_to]}")
                @audits = @audits.where("audits.created_at  <= ? ",Date.parse(params[:date_to]))
            end
        rescue
        end
    rescue
        @audit = []
        @filters = []
    end

end
