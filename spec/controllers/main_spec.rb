require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Main, "index action" do
  before(:each) do
    @post = mock("Twitter::Status")
    Twitter::Base.stub!(:timeline).and_return([@post])
    Memcached.stub!(:get).and_return(@post)
    Memcached.stub!(:set)
  end
  
  def do_get
    dispatch_to(Main, :index) do |controller|
      controller.stub!(:display)
    end
  end
  
  it "should handle an error from the Twitter API" do
    Twitter::Base.any_instance.should_receive(:timeline).and_raise(Twitter::CantConnect)
    do_get.should be_successful
  end
  
  it "should handle an error from Memcached" do
    do_get.should be_successful
  end
end