# coding: utf-8

require "twitter"

class Account
  def initialize(token)
    @rest = Twitter::REST::Client.new(token)
    @stream = Twitter::Streaming::Client.new(token)
    @credentials = @rest.verify_credentials
    @callbacks = {}
  end

  def register_callback(event, &blk)
    @callbacks[event] ||= []
    @callbacks[event] << blk
  end

  def callback(event, obj)
    @callbacks[event].each{|c|c.call(obj)} if @callbacks.key?(event)
  end

  def start
    loop do
      @stream.user do |obj|
        following = false
        case obj
        when Twitter::Tweet
          callback(:tweet, obj) if is_allowed(obj.user.id)
        when Twitter::Streaming::DeletedTweet
          callback(:delete, obj) if is_allowed(obj.user_id)
        when Twitter::Streaming::Event
          callback(:event, obj) if is_allowed(obj.source.id)
        when Twitter::Streaming::FriendList
          @followings = obj
          @followings << @credentials.id
          callback(:friends, obj)
        end
      end
    end
  rescue Exception => ex
    puts "System -> #{ex.message}"
  end

  def is_allowed(user_id)
    following = false
    @followings.each do |id|
      following = true; break if user_id == id
    end
    return following
  end
end
