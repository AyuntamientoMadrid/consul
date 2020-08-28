class RemoveHiddenAtFromModeratedTexts < ActiveRecord::Migration[5.0]
  def change
    remove_column :moderated_texts, :hidden_at, :datetime
  end
end
