class CreateModeratedContents < ActiveRecord::Migration[5.0]
  def change
    create_table :moderated_contents do |t|
      t.string :moderable_type, null: true
      t.integer :moderated_text_id, null: true
      t.integer :moderable_id, null: true
      t.datetime :confirmed_at, null: true
      t.datetime :declined_at, null: true
      t.timestamps
    end

    add_index :moderated_contents, :moderated_text_id
    add_index :moderated_contents, [:moderable_type, :moderable_id]
  end
end
