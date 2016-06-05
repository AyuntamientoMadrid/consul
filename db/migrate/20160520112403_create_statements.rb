class CreateStatements < ActiveRecord::Migration
  def change
    create_table :statements do |t|
      t.integer :audit_id
      t.string :filename

      t.timestamps null: false
    end
  end
end
