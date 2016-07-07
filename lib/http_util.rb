# -*- coding: utf-8 -*-
require 'net/http'
require 'kconv'

#oauth
require 'oauth'

CONSUMER_KEY =
CONSUMER_SECRET =
ACCESS_TOKEN =
ACCESS_TOKEN_SECRET =


class HTTPUtil

public
def HTTPUtil.getWithParams(host,path,params_hash)
  params_arr = params_hash.to_a
  path += params_arr.collect{|elem| elem[0].to_s + '=' + elem[1].to_s }.join('&')
  return RequestAPage(host,path).body
end

def HTTPUtil.postWithParams(host,path,params_hash)
 consumer = OAuth::Consumer.new(
   CONSUMER_KEY,
   CONSUMER_SECRET,
   :site => 'https://api.twitter.com'
 )
 access_token = OAuth::AccessToken.new(
   consumer,
   ACCESS_TOKEN,
   ACCESS_TOKEN_SECRET
 )

  return access_token.post(path,params_hash).body
end

private
#1ページだけリクエスト
def HTTPUtil.RequestAPage(host,path)
  consumer = OAuth::Consumer.new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    :site => 'https://api.twitter.com'
  )
  access_token = OAuth::AccessToken.new(
    consumer,
    ACCESS_TOKEN,
    ACCESS_TOKEN_SECRET
  )

  return access_token.get(path)

#  Net::HTTP.version_1_2
#  req = Net::HTTP::Get.new(path)
#  if user_name && pass
#    req.basic_auth user_name,pass
#  end
#  Net::HTTP.start(host) {|http|
#    return http.request(req)
#  }
end

end
