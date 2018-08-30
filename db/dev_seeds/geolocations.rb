section "Creating Geolocations"  do
  def create_geolocation(proposal_id: nil, investment_id: nil)
    MapLocation.create(latitude: Setting['map_latitude'].to_f + rand(-10..10)/100.to_f,
                       longitude: Setting['map_longitude'].to_f + rand(-10..10)/100.to_f,
                       zoom: Setting['map_zoom'],
                       proposal_id: proposal_id,
                       investment_id: investment_id)
  end

  sample = [*1..Proposal.count].sample
  proposals = Proposal.all.sample(sample).map(&:id)
  proposals.each do |p|
    create_geolocation(proposal_id: p)
  end

  Budget::Investment.find_each do |i|
    create_geolocation(investment_id: i.id)
  end
end
