class Main < Application
  
  def index
    begin
      @posts = $cache.get('tweet')
    rescue Memcached::NotFound
      begin
        @posts = latest_twitter_posts
        $cache.set('tweet', @posts, 60)
      rescue Twitter::CantConnect
        @posts = [DummyPost.new('Ooops! Looks like the Twitter API is not responding. Come back in a bit!')]
      end
    rescue Memcached::ATimeoutOccurred  
      @posts = [DummyPost.new('Oops! Looks like the Twitter cache is out to lunch. Phone Asa and tell him to mend it.')]
    end
    
    render
  end
  
  private
  
  def latest_twitter_posts
    y = YAML.load_file('config/twitter.yml')
    twitter_config = y[:twitter]
    
    twitter = Twitter::Base.new(twitter_config[:email], twitter_config[:password])
    timeline = twitter.timeline(:user)
    return timeline[0..2]
  end
  
  # Dummy internal class
  
  class DummyPost
    attr_accessor :text
    
    def initialize(txt)
      self.text = txt
    end
    
    def created_at
      DateTime.now.to_date
    end
  end
  
end
