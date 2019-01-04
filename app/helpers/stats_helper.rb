module StatsHelper

  def chart_tag(opt={})
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(chart_data(opt))
    content_tag :div, "", opt
  end

  def events_chart_tag(events, opt = {})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(events: events)
    content_tag :div, "", opt
  end

  def visits_chart_tag(opt = {})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(chart_data(opt))
    content_tag :div, "", opt
  end

  def chart_data(opt = {})
    data = nil
    if opt[:id].present?
      data = {opt[:id] => true}
    elsif opt[:event].present?
      data = {event: opt[:event]}
    end
    data
  end

  def graph_link_text(event)
    text = t("admin.stats.graph.#{event}")
    if text.to_s.match(/translation missing/)
      text = event
    end
    text
  end

  def spending_proposals_chart_tag(opt = {})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(spending_proposals: true)
    content_tag :div, "", opt
  end

  def budget_investments_chart_tag(opt = {})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(budget_investments: true)
    content_tag :div, "", opt
  end

  def number_to_stats_percentage(number, options = {})
    number_to_percentage(number, { strip_insignificant_zeros: true, precision: 2 }.merge(options))
  end

  def number_with_info_tags(number, text, html_class: "")
    content_tag :p, class: "number-with-info #{html_class}".strip do
      content_tag(:span, number, class: "number") + content_tag(:span, text, class: "info")
    end
  end
end
