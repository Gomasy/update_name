# coding: utf-8

require "cgi"

def update_name(obj, name)
  @rest.update_profile(:name => name)
  @rest.update(
    "@#{obj.user.screen_name} のせいで「#{name}」に改名する羽目になりました",
    :in_reply_to_status_id => obj.id
  )
  puts "System -> renamed to \'#{name}\' by @#{obj.user.screen_name}"
end

register_callback(:tweet) do |obj|
  following = false
  screen_name = @credentials.screen_name
  @followings.each do |id|
    if obj.user.id == id
      following = true
      break
    end
  end
  if following
    if obj.retweeted_status.retweeted?
      case CGI.unescapeHTML(obj.text)
      when /^.*@#{screen_name}\supdate_name\s(.+?)$/
        update_name(obj, $1)
      when /^(.+?)(?:\(\s?@#{screen_name}\s?\)|（\s?@#{screen_name}\s?）)$/
        update_name(obj, $1)
      end
    end
  end
end
