class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users, :options => 'DEFAULT CHARSET=utf8') do |t|
      t.column :user_name,:string,:null => false
      t.column :user_id,:integer,:null => false
      t.column :location,:string,:null => false
      t.column :image_url,:string,:null => false
      t.column :is_added,:boolean,:null => false,:default => false
    end
  end

  def self.down
    drop_table :users
  end
end
