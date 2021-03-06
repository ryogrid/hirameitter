# coding: utf-8
# -*- coding: utf-8 -*-
require 'my_twitter'
require 'uri'

class IdeaController < ApplicationController
  DEBUG = false

    def index
      redirect_to :action => "top"
    end

    def top
      @use_introduction = true

      @pages = Twit.paginate(:page => params[:page],:per_page => 20,:order => 'id desc')
      @show_descendant_count = true
    end

    # delete spam (english only posts)
    def delete_spam
      twit = Twit.find(:all)
      twit.each{ |elem|
        if elem.text =~ /.*([一-龠]|[ぁ-ん]|[ァ-ン]|[ｧ-ﾝ]).*/
        else 
          puts elem.text
          elem.destroy()
        end
      }
    end
    
    def crawl
      for_update_twits = Array.new #statusに追加すべき新規twit
      replies = Twitter.get_replies()
      replies.reverse!
      replies.each{ |elem|
        begin

          # ひらめいったーの投稿なら無視する
          # elem[1] には user_name が入っている
          if elem[1].include?("hirameki")
            next
          end

          user = User.find(:first,:conditions => ['user_id = ?',elem[2]])
          unless user
            tmp_user = User.new(:user_name => elem[1],:user_id => elem[2],:image_url => elem[3],:location => (elem[4] || ''))
            tmp_user.save
            user = tmp_user
          end
          
          if user.user_name != elem[1]
            user.user_name = elem[1]
            user.update()
          end
          
          safe_content = replace_escaped_strs(elem[5].gsub(/^@hirameki\s/,'').gsub(/@/,''))
          twit = Twit.find(:first,:conditions => ['text = ?',safe_content])

          # 英字だけの投稿を無視する
          unless safe_content =~ /.*([一-龠]|[ぁ-ん]|[ァ-ン]|[ｧ-ﾝ]).*/
            next
          end
            
          # RTの投稿とpaper.liの投稿を無視する
          if safe_content =~ /^RT .*/ || safe_content =~ /.* RT .*/ || safe_content =~ /.*紙が更新されました.*/ || safe_content =~ /.*is out.*/
            next
          end

          unless twit
            new_twit = Twit.new(:twit_id => elem[0],:text => safe_content,:created_at => Time.now)
            new_twit.user = user
            new_twit.save #idを使うためにひとまず保存
            
            #他のひらめきを参照していた場合
            if elem[5].match(/h:(\d+)/) && (parent_id = elem[5].match(/h:(\d+)/).to_a()[1])
              #参照先に関連付ける
              if parent_id.to_i < new_twit.id #未来のtwitや自分自身のIDを参照していない限り
                new_twit.parent_id = parent_id.to_i
                ancestors = new_twit.get_ancestors_and_brother()
                already_sended = Hash.new #送信してしまったユーザのリスト
                #参照先の発言ユーザに通知
                begin
                  ancestors.each{ |each_ancestor_id|
                    tmp_twit = Twit.find_by_id(each_ancestor_id)
                    unless already_sended.has_key?(tmp_twit.user.id) #まだ送信していないユーザであれば
                      Twitter.update('@' + tmp_twit.user.user_name + ' あなたのアイデアかあなたがコメントしたアイデアにのっかりひらめきｈ:' + new_twit.id.to_s + 'がつきました→' + url_for(:action => "twit",:id => parent_id)) unless DEBUG
                      already_sended[tmp_twit.user.id] = "sended" #送信済みとマーク
                    end
                  }
                rescue => e
                  d e
                end
              end
            end

            new_twit.save

            for_update_twits << new_twit
          end
        rescue => e
          d e
        end
      }

      #新規twitsを追加してしまう
      #文字エンティティをデコードする必要あり
      for_update_twits.each{ |each_twit|
        begin
          Twitter.update('h:' + each_twit.id.to_s + ' ' + each_twit.text + ' from id:' + each_twit.user.user_name + ' スターをつける→' + url_for(:action => 'twit',:id => each_twit.id)) unless DEBUG
        rescue => e
          d e
        end
      }
    end
  
    #ユーザアイコンのリストを更新する    
    def update_icons
      all_users = User.find(:all)
      divided = all_users.length.divmod(24)
      now_hour = Time.now.hour
      #23時なら余りのも更新
      if now_hour == 23
        to_updates = all_users[divided[0]*now_hour .. divided[0]*(now_hour+1)]
      else
        to_updates = all_users[divided[0]*now_hour .. (divided[0]*(now_hour+1) + divided[1])]
      end
      
      to_updates.each{|a_user|
        if (tmp_path = Twitter.get_user_icon_path(a_user.user_name))
          a_user.image_url = tmp_path
          a_user.save
        end
      }      
    end
    
    #一定時間ごとに過去のアイデアを投稿するために呼び出す
    def post_past_twit
      all_twits = Twit.count
      a_twit = Twit.find(:first,:conditions => ['id = ?',rand(all_twits - 1)])

      begin
        Twitter.update('(掘り返し) h：' + a_twit.id.to_s + ' ' + a_twit.text + ' from id:' + a_twit.user.user_name + ' ' + url_for(:action => 'twit',:id => a_twit.id))
      rescue => e
        d e
      end      
    end

    def twit
      id = params[:id]
      if id
        @twit = Twit.find_by_id(id)
        @is_recursive = true #スレッド表示する
      end
      @title = "ひらめいったー  - " + @twit.text
    end

    def each_user
      user_name = params[:id]
      if user_name
        @show_descendant_count = true
        user_id = User.find(:first,:conditions => ["user_name = ?",user_name]).id
        @pages = Twit.paginate(:page => params[:page],:per_page => 20,:conditions => ["user_id = ?",user_id],:order => 'created_at desc')
        @title = "ひらめいったー  - " + @pages[0].user.user_name + "のひらめき達"
      end
    end
end
