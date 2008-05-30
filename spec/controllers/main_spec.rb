require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Main, "index action" do
  before(:each) do
    @mock_posts = [
      mock('Post1', :text => 'Ding Dong', :created_at => DateTime.now.to_date),
      mock('Post2', :text => 'Ping Pong', :created_at => DateTime.now.to_date),
      mock('Post3', :text => 'King Kong', :created_at => DateTime.now.to_date)
    ]
    
    $cache = mock('Memcached')
    $cache.stub!(:get).and_return(@mock_posts)
    $cache.stub!(:set)
    
    @mock_twitter = mock('Twitter::Base')
    @mock_twitter.stub!(:timeline).and_return(@mock_posts)
    Twitter::Base.stub!(:new).and_return(@mock_twitter)
  end
  
  def do_get
    dispatch_to(Main, :index) do |controller|
      controller.stub!(:display)
    end
  end
  
  it "should display some tweets from cache" do
    $cache.should_receive(:get).once.and_return(@mock_posts)
    do_get.should respond_successfully
  end
  
  it "should reset the cache from Twitter" do
    $cache.stub!(:get).and_raise(Memcached::NotFound)
    $cache.should_receive(:set).once
    @mock_twitter.should_receive(:timeline).once.and_return(@mock_posts)
    do_get.should respond_successfully
  end
  
  it "should cope with Memcached timeouts" do
    $cache.stub!(:get).and_raise(Memcached::ATimeoutOccurred)
    do_get.should respond_successfully
  end
  
  it "should cope with Twitter API timeouts" do
    $cache.stub!(:get).and_raise(Memcached::NotFound)
    Twitter::Base.stub!(:new).and_raise(Twitter::CantConnect)
    do_get.should respond_successfully
  end
end