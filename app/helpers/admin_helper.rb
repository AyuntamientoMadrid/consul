module AdminHelper

  def side_menu
    if namespace == "moderation/budgets"
      render "/moderation/menu"
    else
      render "/#{namespace}/menu"
    end
  end

  def namespaced_root_path
    "/#{namespace}"
  end

  def namespaced_header_title
    if namespace == "moderation/budgets"
      t("moderation.header.title")
    else
      t("#{namespace}.header.title")
    end
  end

  def menu_moderated_content?
    moderated_sections.include?(controller_name) && controller.class.parent != Admin::Legislation
  end

  def moderated_sections
    ["hidden_proposals", "debates", "comments", "hidden_users", "activity",
     "hidden_budget_investments", "moderated_texts", "imports", "auto_moderated_content"]
  end

  def menu_budgets?
    controller_name.starts_with?("budget")
  end

  def menu_proposals?
    %w[proposals].include?(controller_name)
  end

  def menu_polls?
    %w[polls active_polls recounts results questions answers].include?(controller_name) ||
    controller.class.parent == Admin::Poll::Questions::Answers
  end

  def menu_booths?
    %w[officers booths shifts booth_assignments officer_assignments].include?(controller_name)
  end

  def menu_profiles?
    %w[superadministrators administrators sures_administrators section_administrators consultants 
      editors organizations officials moderators valuators managers users parbudget_editors parbudget_readers
      complan_editors complan_readers].include?(controller_name)
  end

  def menu_settings?
    ["settings", "tags", "geozones", "images", "content_blocks"].include?(controller_name) &&
    controller.class.parent != Admin::Poll::Questions::Answers
  end

  def menu_customization?
    ["pages", "banners", "information_texts", "documents", "sgs","event_agends"].include?(controller_name) ||
    menu_homepage? || menu_pages? || menu_sg?
  end

  def menu_sures?
    ["sures", "actuations", "customizes", "searchs"].include?(controller_name) || menu_sures_customize? ||  menu_sures_actuation? || menu_sures_search?
  end

  def menu_sures_actuation? 
    ["actuations"].include?(controller_name) && controller.class.parent.to_s == "Admin::Sures"
  end

  def menu_sures_customize?
    ["customizes","customize_cards"].include?(controller_name) && controller.class.parent.to_s == "Admin::Sures"
  end

  def menu_sures_search?
    ["searchs_settings"].include?(controller_name) && controller.class.parent.to_s == "Admin::Sures"
  end

  def menu_homepage?
    ["homepage", "cards"].include?(controller_name) && params[:page_id].nil?
  end

  def menu_sg?
    ["sgs"].include?(controller_name)
  end

  def menu_pages?
    ["pages", "cards"].include?(controller_name) && params[:page_id].present?
  end

  def menu_dashboard?
    ["actions", "administrator_tasks"].include?(controller_name)
  end

  def menu_parbudget?   
    controller.class.parent.to_s == "Admin::Parbudget" && !["editors", "readers"].include?(controller_name)
  end

  def menu_parbudget_maintence?
    ["ambits", "topics", "centers", "projects", "responsibles", "meetings"].include?(controller_name) && controller.class.parent.to_s == "Admin::Parbudget"
  end

  def menu_parbudget_audits?
    ["audits"].include?(controller_name) && controller.class.parent.to_s == "Admin::Parbudget"
  end

  def menu_complan?   
    controller.class.parent.to_s == "Admin::Complan" && !["editors", "readers"].include?(controller_name)
  end

  def menu_complan_maintence?
    ["projects", "performances", "centers", "strategies", "typologies", "thecnical_tables"].include?(controller_name) && controller.class.parent.to_s == "Admin::Complan"
  end

  def menu_complan_audits?
    ["audits"].include?(controller_name) && controller.class.parent.to_s == "Admin::Complan"
  end

  def moderated_texts_section?
    controller_name == "moderated_texts" || moderated_texts_import_section?
  end

  def moderated_texts_import_section?
    controller_name == "imports" && controller.class.parent == Admin::ModeratedTexts
  end

  def show_moderation_buttons?(comment)
    comment.moderated_contents.map(&:declined_at).all? ||
    comment.moderated_contents.map(&:confirmed_at).all?
  end

  def moderated_date(comment)
    moderated_content = comment.moderated_contents.first
    date = comment.moderated_contents.map(&:declined_at).all? ? moderated_content.declined_at : moderated_content.confirmed_at
    I18n.l(date, format: :datetime)
  end

  def official_level_options
    options = [["", 0]]
    (1..5).each do |i|
      options << [[t("admin.officials.level_#{i}"), setting["official_level_#{i}_name"]].compact.join(": "), i]
    end
    options
  end

  def admin_select_options
    Administrator.all.order("users.username asc").includes(:user).collect { |v| [ v.name, v.id ] }
  end

  def admin_submit_action(resource)
    resource.persisted? ? "edit" : "new"
  end

  def user_roles(user)
    roles = []
    roles << :superadmin if user.super_administrator?
    roles << :admin if user.administrator?
    roles << :sures if user.sures?
    roles << :moderator if user.moderator?
    roles << :valuator if user.valuator?
    roles << :manager if user.manager?
    roles << :poll_officer if user.poll_officer?
    roles << :official if user.official?
    roles << :organization if user.organization?
    roles
  end

  def display_user_roles(user)
    user_roles(user).join(", ")
  end

  private

    def namespace
      controller.class.name.downcase.split("::").first
    end

end
