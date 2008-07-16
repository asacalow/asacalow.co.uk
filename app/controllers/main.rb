class Main < Application
  
  def index
    @twitter = cached_post('twitter') || cache('twitter', latest_twitter_post) || emergency_cached_post('twitter') || last_resort_post
    @github = cached_post('github') || cache('github', latest_github_post) || emergency_cached_post('github') || last_resort_post
    render
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
    $cache.set(post_type, post, 1.minute)
    $cache.set("old_#{post_type}", post, 1.day)
  end
  
  # Dummy internal class
  
  class Post
    attr_accessor :text
    attr_accessor :created_at
    
    def initialize(txt, created_at = DateTime.now.to_date)
      self.text = txt
      self.created_at = created_at
    end
  end
  
end
