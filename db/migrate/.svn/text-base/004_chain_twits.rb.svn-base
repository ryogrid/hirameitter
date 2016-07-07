class ChainTwits < ActiveRecord::Migration
  def self.up
    Twit.find_all().each{ |each_twit|
      if each_twit.text.match(/twit\/(\d+)/) && (parent_id = each_twit.text.match(/twit\/(\d+)/).to_a()[1])
        each_twit.parent_id = parent_id.to_i
        each_twit.save
      end
    }
  end

  def self.down
    Twit.update_all("parent_id = NULL")
  end

end
