class Main < Merb::Controller

  def _template_location(action, type = nil, controller = controller_name)
    controller == "layout" ? "layout.#{action}.#{type}" : "#{action}.#{type}"
  end

  def index
    begin
      @post = $cache.get('tweet')
    rescue Memcached::NotFound
      @post = latest_twitter_post
      $cache.set('tweet', @post, 60)
    end
    
    render
  end
  
  private
  
  def latest_twitter_post
    y = YAML.load_file('config/twitter.yml')
    twitter_config = y[:twitter]
    
    twitter = Twitter::Base.new(twitter_config[:email], twitter_config[:password])
    timeline = twitter.timeline(:user)
    return timeline.first
  end
  
end