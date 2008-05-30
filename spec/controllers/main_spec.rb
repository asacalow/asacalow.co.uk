require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Main, "index action" do
  before(:each) do
    @mock_cache = mock('Memcached')
    @mock_cache.stub!(:get).and_return([])
    @mock_cache.stub!(:set)
    Memcached.stub!(:new).and_return(@mock_cache)
    
    @mock_twitter = mock('Twitter::Base')
    @mock_twitter.stub!(:timeline).and_return([])
    Twitter::Base.stub!(:new).and_return(@mock_twitter)
  end
  
  def do_get
    dispatch_to(Main, :index) do |controller|
      controller.stub!(:display)
    end
  end
  
  it "should display some tweets from cache" do
    @mock_cache.should_receive(:get).once.and_return([])
    do_get.should respond_successfully
  end
  
  it "should reset the cache from Twitter" do
    @mock_cache.stub!(:get).and_raise(Memcached::NotFound)
    do_get.should respond_successfully
  end
  
  it "should cope with Memcached timeouts" do
    @mock_cache.stub!(:get).and_raise(Memcached::ATimeoutOccurred)
    do_get.should respond_successfully
  end
  
  it "should cope with Twitter API timeouts" do
    @mock_cache.stub!(:get).and_raise(Memcached::NotFound)
    Twitter::Base.stub!(:new).and_raise(Twitter::CantConnect)
    do_get.should respond_successfully
  end
end