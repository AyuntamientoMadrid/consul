class CreateAdminReaders < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_readers do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
