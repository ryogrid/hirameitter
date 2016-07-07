# -*- coding: euc-jp -*-
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def generate_time_str(time)
    result_str = ''
    day2 = Time.now
    day1 = time
    years = (day2 - day1).divmod(24*60*60*365)
    days = years[1].divmod(24*60*60)
    hours = days[1].divmod(60*60)
    mins = hours[1].divmod(60)

    if years[0] != 0
      return result_str += "more than #{years[0].to_i} years ago"
    end
    
    if days[0] != 0
      return result_str += "#{days[0].to_i} days ago"
    end

    if hours[0] != 0
      return result_str += "#{hours[0].to_i} hours ago"
    end

    if mins[0] != 0
      return result_str += "#{mins[0].to_i} minutes ago"
    end

    return result_str += "#{mins[1].to_i} seconds ago"
  end

  # truncateメソッドを旧仕様に合わせる
  # http://www.kagitaku.com/diary/2010/08/27/ruby1-8-7-truncate.html
  def truncate(text, length = 30, truncate_string = "...")
    if text.nil?
      return
    end
    
    l = length - truncate_string.chars.to_a.size
    return (text.chars.to_a.size > length ? text.chars.to_a[0...l].join + truncate_string : text).to_s
  end  
end
