module IdeaHelper

# twit_instance: Twit
def gen_tweet_str_with_link(twit_instance)
  tmp_hirameki_ref = ""
  twit_instance.text.gsub(/h:(\d+)/) {
    tmp_hirameki_ref = link_to( "h:" + $1, {:action => 'twit',:id => $1}, {:target => "_blank"} )
  }.gsub(/http:\/\/#{ApplicationController::SITE_DOMAIN}\/idea\/twit\/(\d+)/){ 
    tmp_hirameki_ref = link_to("h:" + $1, {:action => 'twit',:id => $1}, {:target => "_blank"} )
  }
  
  tmp_str = h(twit_instance.text).gsub(/h:(\d+)/){ "hirameki_tmp" }.gsub(/http:\/\/#{ApplicationController::SITE_DOMAIN}\/idea\/twit\/(\d+)/){
    "hirameki_tmp"
  }

  return raw( 'h:' + twit_instance.id.to_s + ' ' + url2link_of_string(tmp_str).gsub(/hirameki_tmp/,tmp_hirameki_ref) )
end
    
def url2link_of_string(html_string,options={})
  target=options[:target] || '_blank'
  URI.extract(html_string).each{|url|
    html_string.gsub!(url,"<a href='#{url}' target='#{target}'>#{url}</a>")
  }
  return html_string
end

end
