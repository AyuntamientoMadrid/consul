module GeozonesHelper

  def geozone_name(geozonable)
    geozonable.geozone ? geozonable.geozone.name : t("geozones.none")
  end

  def geozone_select_options
    Geozone.all.order(name: :asc).collect { |g| [ g.name, g.id ] }
  end

  def my_geozone?(geozone, geozonable)
    geozone == geozonable.geozone
  end

  def geozone_name_from_id(g_id)
    @all_geozones ||= Geozone.all.collect{ |g| [ g.id, g.name ] }.to_h
    @all_geozones[g_id] || t("geozones.none")
  end

  def geozonables_path(geozonable_type, geozonable_name)
    case geozonable_type
    when 'debate'
      debates_path(search: geozonable_name)
    when 'proposal'
      proposals_path(search: geozonable_name)
    else
      '#'
    end
  end

  def map_geozonable_path(geozonable)
    case geozonable
    when 'debate'
      map_debates_path
    when 'proposal'
      map_proposals_path
    else
      '#'
    end
  end

  def show_map(geozonable)
    feature?("geozones.#{geozonable.pluralize}.maps")
  end

  def show_links(geozonable)
    feature?("geozones.#{geozonable.pluralize}.links")
  end

end
