class AddFieldsToStatement < ActiveRecord::Migration
  def change
    add_column :statements, :title, :string
    add_column :statements, :body, :text
  end
end
