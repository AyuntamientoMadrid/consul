module Admin::AuditHelper

    def audit_create(resource)
        audit = Audit.create(
                    action: "create_#{resource.class.to_s.downcase.split('::')[1]}",
                    user_id: current_user.id,
                    resource: controller_name,
                    description: t('admin.menu.audits_desc.create', 
                        resource: "#{t("admin.menu.audit_tabs_sing.#{resource.class.to_s.downcase.split('::')[1]}")}", 
                        id: resource.id),
                    audit_type: resource.class.parent.to_s.downcase
                )
    end

    def audit_update(resource)
        audit = Audit.create(
            action: "update_#{resource.class.to_s.downcase.split('::')[1]}",
            user_id: current_user.id,
            resource: controller_name,
            description: t('admin.menu.audits_desc.update',
                resource: "#{t("admin.menu.audit_tabs_sing.#{resource.class.to_s.downcase.split('::')[1]}")}", 
                id: resource.id),
            audit_type: resource.class.parent.to_s.downcase
        )
    end

    def audit_delete(resource, id, type)
        audit = Audit.create(
            action: "delete_#{resource}",
            user_id: current_user.id,
            resource: controller_name,
            description: t('admin.menu.audits_desc.delete', 
                resource: "#{t("admin.menu.audit_tabs_sing.#{resource}")}", 
                id: id),
            audit_type: type
        )
    end

end
