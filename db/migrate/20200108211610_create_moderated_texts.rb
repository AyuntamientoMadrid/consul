class CreateModeratedTexts < ActiveRecord::Migration[5.0]
  def change
    create_table :moderated_texts do |t|
      t.string :text
      t.timestamps
      t.datetime :hidden_at, index: true
    end

    add_index :moderated_texts, :text, unique: true
  end
end
