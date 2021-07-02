class CreateAudits < ActiveRecord::Migration[5.0]
  def change
    create_table :audits do |t|
      t.string :action
      t.belongs_to :user, index: true, foreign_key: true
      t.string :resource
      t.string :description
      t.string :audit_type

      t.timestamps null: false
    end
  end
end
