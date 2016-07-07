class CreateTwits < ActiveRecord::Migration
  def self.up
    create_table(:twits, :options => 'DEFAULT CHARSET=utf8') do |t|
      t.column :text,:string,:null => false
      t.column :user_id,:integer,:null => false
      #twit_idは現在使用していない
      t.column :twit_id,:integer,:null => false
      t.column :created_at,:datetime,:null => false
    end
  end

  def self.down
    drop_table :twits
  end
end
