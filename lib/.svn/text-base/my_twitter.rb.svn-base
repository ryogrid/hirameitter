# -*- coding: utf-8 -*-
require 'net/http'
require 'http_util'
require 'uri'
require 'kconv'
require 'rexml/document'

#for using scrapi
require 'scrapi'
require 'open-uri'

#for using yaml
require 'yaml'

require 'json'
require 'jcode'

class Twitter
TWITTER_HOST = 'api.twitter.com' # 使用されない。
PUBLIC_TIMELINE_PATH = '/statuses/public_timeline.xml'
REPLIES_PATH = "/1.1/statuses/mentions_timeline.json"
BE_FRIEND_PATH = "/friendships/create/"
FOLLOWERS_PATH = "/statuses/friends.xml"
USER_INFO_PATH = "/1.1/users/show.json?"
UPDATE_PATH = "/1.1/statuses/update.json"

TWITTER_USER_NAME = 'hirameki'
# TWITTER_USER_NAME = 'hiramekitest'

  public
  #[twitのID,Userの名前,UserのID,Userの写真のURL,UserのLocation,発言内容(文字参照はそのままにしてある)]という形式の配列が返る
  def self.get_public_timeline(id = nil)
    params_hash = Hash.new
    question = ''
    if id
      params_hash['since_id'] = id
      question = '?'
    end

    result_xml = HTTPUtil.getWithParams(TWITTER_HOST,PUBLIC_TIMELINE_PATH + question,params_hash)

    doc = REXML::Document.new result_xml

    status_ids = doc.root.get_elements('/statuses/status/id')
    user_names = doc.root.get_elements('/statuses/status/user/screen_name')
    user_ids = doc.root.get_elements('/statuses/status/user/id')
    user_images = doc.root.get_elements('/statuses/status/user/profile_image_url')
    user_locations = doc.root.get_elements('/statuses/status/user/location')
    texts  = doc.root.get_elements('/statuses/status/text')

    result_arr = Array.new
    user_names.each_index{|index|
      result_arr << [status_ids[index].text.to_i,user_names[index].text,user_ids[index].text.to_i,user_images[index].text,user_locations[index].text,texts[index].get_text.to_s]
    }

    return result_arr
  end

  #[twitのID,Userの名前,UserのID,Userの写真のURL,UserのLocation,発言内容(文字参照はそのままにしてある)]という形式の配列が返る
  def self.get_replies()
    params_hash = Hash.new
    question = ''

    params_hash['count'] = 200
    question = '?'

    result_json = HTTPUtil.getWithParams(TWITTER_HOST,REPLIES_PATH + question,params_hash)
    result_obj = JSON.parse(result_json,{})

    # p result_obj
    result_arr = Array.new
    result_obj.each_index{|index|
      result_arr << [result_obj[index]['id_str'],result_obj[index]['user']['screen_name'],result_obj[index]['user']['id_str'],result_obj[index]['user']['profile_image_url'],result_obj[index]['user']['location'],result_obj[index]['text']]
    }

    return result_arr
  end

  #成功したらtrueを返す
  def self.be_friend(id_or_user_name)
    params_hash = Hash.new

    begin
      result_xml = HTTPUtil.getWithParams(TWITTER_HOST,BE_FRIEND_PATH + id_or_user_name + ".xml",params_hash)
      doc = REXML::Document.new result_xml
    rescue Timeout::Error
      return false
    rescue => e
      return false
    else
      return true
    end
  end

  #idの配列を返す
  def self.get_followers
    params_hash = Hash.new

    result_xml = HTTPUtil.getWithParams(TWITTER_HOST,FOLLOWERS_PATH,params_hash)
    doc = REXML::Document.new result_xml

    ids = doc.root.get_elements('/users/user/screen_name')

    result_arr = Array.new
    ids.each{ |elem|
      result_arr << elem.text
    }

    return result_arr
  end

  def self.get_user_icon_path(user_name)
      params_hash = Hash.new
      params_hash['screen_name'] = user_name
      result_json = HTTPUtil.getWithParams(TWITTER_HOST,USER_INFO_PATH,params_hash)

      result_obj = JSON.parse(result_json,{})

      if result_obj['profile_image_url']
        return result_obj['profile_image_url']
      else
        return nil
      end
  end
  
  def self.get_target_user_friends(user_name)
    params_hash = Hash.new
    first_html = HTTPUtil.getWithParams(TWITTER_HOST,'/' + user_name + "/friends",params_hash)

    follower_count_arr = first_html.scan(/follows\s(.+)\speople/)
    follower_count = follower_count_arr[0][0].to_i

    twitter_scraper = Scraper.define do
      process "span.fn", "users1[]"=>:text
      process "span.uid", "users2[]"=>:text
      result :users1,:users2
    end

    first_friends = twitter_scraper.scrape(first_html,:parser => :html_parser,:timeout => 300)

    #[アーティスト名,タイトル]という二次元配列を要素として持つ配列,indexの小さい方がトップ
    result = Array.new

    first_friends.users1.each {|elem|
        result << elem
    }

    first_friends.users2.each{ |elem|
        result << elem
    }

    additional_page_count = ((follower_count - 20) + 19).divmod(20)[0]

    for i in 2..(additional_page_count+2)
      params_hash['page'] = i.to_s
      tmp_html = HTTPUtil.getWithParams(TWITTER_HOST,'/' + user_name + "/friends?",params_hash)
      tmp_friends = twitter_scraper.scrape(tmp_html,:parser => :html_parser,:timeout => 300)
      if tmp_friends.users1
        tmp_friends.users1.each {|elem|
            result << elem
        }
      end

      if tmp_friends.users2
        tmp_friends.users2.each{ |elem|
            result << elem
        }
      end
    end

    return result
  end

  def self.update(str)
    params_hash = Hash.new

    #params_hash['status'] = URI.encode(str)
    params_hash['status'] = str
    result_html = HTTPUtil.postWithParams(TWITTER_HOST,UPDATE_PATH,params_hash)
  end

  def self.crawl_user_list
    if FileTest.exist?('./users_hash.yml')
      result_hash = YAML::load_file("./users_hash.yml")
    else
      result_hash = Hash.new
    end
    target_user_arr = ['bulkneets','dankogai','otsune','kogure','amachang','akiyan','ryo_grid','amachang','jazzanova','takesako','miyagawa']
    #target_user_arr = ['bulkneets']
    target_user_arr.each{ |each_user|
      begin
        tmp_result = Twitter.get_target_user_friends(each_user)
        tmp_result.each{ |elem|
          result_hash[elem.to_s] = elem.to_s
        }
      rescue => e
      end
    }

    result_hash.keys.each{ |elem|
      puts elem
    }

    open('./users_hash.yml','w').write(result_hash.to_yaml)
  end

  def self.make_friends
    users_hash = YAML::load_file("./users_hash.yml")
    
    if FileTest.exist?("./finished_hash.yml")    
      finished_hash = YAML::load_file("./finished_hash.yml")
    else
      finished_hash = Hash.new    
    end
    count = 0

    users_hash.keys.each{ |user_name|
       if ! finished_hash.include?(user_name)
          begin
            is_succeed = be_friend(user_name)
            if is_succeed
              finished_hash[user_name] = user_name
              open('./finished_hash.yml','w'){ |file|
                file.write(finished_hash.to_yaml)
              }
              count+=1
              puts count.to_s + 'times finish.'
            end
            sleep 65
          rescue => e
            puts e.to_s
          end
      else
        puts 'passed ' + user_name + '.'
      end
    }
  end

end

# Twitter.get_replies.each{ |elem|
#   puts elem[5].tosjis
# }

#Twitter.crawl_user_list()

#Twitter.make_friends()

# Twitter.get_user_icon_path("ryo_grid")

#p Twitter.update("ひらめいったーだよー")

#p Twitter.get_replies()

# p Twitter.update("あいうえお")

