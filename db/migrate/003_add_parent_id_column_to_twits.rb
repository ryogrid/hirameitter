class AddParentIdColumnToTwits < ActiveRecord::Migration
  def self.up
    add_column :twits,:parent_id,:integer
  end

  def self.down
    remove_column :twits,:twit_id
  end
end
