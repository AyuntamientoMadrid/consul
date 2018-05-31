namespace :max_supportable_headings do
  desc "Set max_votable_headings value in max_supportable_headings in existing Budget:Group"
  task set_value: :environment do
    Budget::Group.all.each do |group|
      group.update(max_supportable_headings: group.max_votable_headings)
    end
  end
end
