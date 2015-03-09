require "cgi"

def update_name(obj, name)
  name.sub!(/@|＠/, "@\u200b")
  twitter.update_profile(:name => name)
  twitter.update(
    "@#{obj.user.screen_name} のせいで「#{name}」に改名する羽目になりました",
    :in_reply_to_status_id => obj.id
  )
  puts "System -> renamed to \'#{name}\' by @#{obj.user.screen_name}"
rescue Twitter::Error::Forbidden => ex
  twitter.update(
    "@#{obj.user.screen_name} #{ex.message}",
    :in_reply_to_status_id => obj.id
  )
end

on_event(:tweet) do |obj|
  [
    /^(?!RT).*@#{screen_name}\supdate_name\s((.|\n)+?)$/,
    /^(?!RT)((.|\n)+?)(\(\s?@#{screen_name}\s?\)|（\s?@#{screen_name}\s?）)$/
  ].each do |ptn|
    if CGI.unescapeHTML(obj.text) =~ ptn
      update_name(obj, $1)
      break
    end
  end
end
