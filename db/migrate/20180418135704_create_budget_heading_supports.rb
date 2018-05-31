class CreateBudgetHeadingSupports < ActiveRecord::Migration
  def change
    create_table :budget_heading_supports do |t|
      t.references :user
      t.references :budget_heading

      t.timestamps null: false
    end
  end
end
