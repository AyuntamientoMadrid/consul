class AddColumnHourEventAgents < ActiveRecord::Migration[5.0]
  def up
    add_column :event_agends, :hour_to, :string
  end

  def down
    remove_column :event_agends, :hour_to
  end
end