# Make the app's "gems" directory a place where gems are loaded from
Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

# Make the app's "lib" directory a place where ruby files get "require"d from
$LOAD_PATH.unshift(Merb.root / "lib")


Merb::Config.use do |c|
  
  ### Sets up a custom session id key, if you want to piggyback sessions of other applications
  ### with the cookie session store. If not specified, defaults to '_session_id'.
  # c[:session_id_key] = '_session_id'
  
  c[:session_secret_key]  = '539745e52ac60fc4705caa9b9261ce267ac16dc7'
  c[:session_store] = 'cookie'
end  

use_test :rspec

### Add your other dependencies here

dependency "merb_helpers"

Merb::BootLoader.after_app_loads do
  # require everything
  require "twitter"
  require "yaml"
  require "memcached"
  require "redcloth"
  
  # set up my memcached server here...
  $cache = Memcached.new("127.0.0.1:11211")
end
