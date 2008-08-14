require 'rubygems'
require 'erubis'
require 'sinatra'
require 'memcached'
require 'simple-rss'
require 'open-uri'
require 'cgi'

configure do
  $cache = Memcached.new("127.0.0.1:11211")
end

get '/' do
  h = Hizzle.new
  @twitter = h.twitter_post
  @github = h.github_post
  input = File.read('yesmate.html.erb')
  erubis = Erubis::Eruby.new(input)
  erubis.result(binding)
end

class Hizzle
  
  def twitter_post
    cached_post('twitter') || cache('twitter', latest_twitter_post) || emergency_cached_post('twitter') || last_resort_post
  end
  
  def github_post
    cached_post('github') || cache('github', latest_github_post) || emergency_cached_post('github') || last_resort_post
  end
  
  def hack_post
    last_resort_post
  end
  
  private
  
  def latest_twitter_post
    begin
      feed = SimpleRSS.parse open('http://twitter.com/statuses/user_timeline/14473977.atom')
      item = feed.items.first
      return Post.new(item.title.gsub(/asacalow: /, ''), item.published)
    rescue
      nil
    end
  end
  
  def latest_github_post
    feed = SimpleRSS.parse open('http://github.com/asacalow.atom')
    item = feed.items.first
    return Post.new("#{item.title}#{item.content}", item.published)
  end
  
  def cached_post(post_type)
    $cache.get(post_type) rescue nil
  end
  
  def emergency_cached_post(post_type)
    $cache.get("old_#{post_type}") rescue nil
  end
  
  def last_resort_post
    Post.new("Oops, looks like the site has gone west. If you wouldn't mind awfully, give Asa a ring and get him to mend it")
  end
  
  def cache(post_type, post)
    $cache.set(post_type, post, 60)
    $cache.set("old_#{post_type}", post, 60 * 60 * 24)
  end
  
  # Dummy internal class
  
  class Post
    attr_accessor :text
    attr_accessor :created_at
    
    def initialize(txt, created_at = Date.today)
      self.text = txt
      self.created_at = created_at
    end
  end
end

helpers do
  def linkify(string)
    regex = Regexp.new '(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'
    string.gsub( regex, '<a href="\1">\1</a>' )
  end
  
  def time_ago_in_words(from_time, to_time = Time.now.utc)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round

    case distance_in_minutes
      when 0..1            then '1 minute' 
      when 2..44           then "#{distance_in_minutes} minutes"
      when 45..89          then 'about 1 hour'
      when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
      when 1440..2879      then '1 day'
      when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
      when 43200..86399    then 'about 1 month'
      when 86400..525599   then "#{(distance_in_minutes / 43200).round} months"
      when 525600..1051199 then 'about 1 year'
      else  
    end  
  end     
end