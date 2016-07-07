# -*- coding: utf-8 -*-
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
#  protect_from_forgery # added from clean 0608
  SITE_DOMAIN = "ryo.hayamin.com"
  
  helper_method :d

  # def initialize
  #   @logger = Logger.new("#{RAILS_ROOT}/./logger_log.log")
  #   @logger.level = Logger::DEBUG
  # end

  #ロガーに与えられたパラメータを出力する
  def d(str)
    # @logger.debug str
    logger.debug str
  end

  def replace_escaped_strs(str)
    return str.gsub(/&quot;/,'"').gsub(/&amp;/,'&').gsub(/&lt;/,'<').gsub(/&gt;/,'>')
  end
  
end
