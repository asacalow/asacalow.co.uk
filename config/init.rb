# Move this to application.rb if you want it to be reloadable in dev mode.
Merb::Router.prepare do |r|
  r.match('/').to(:controller => 'main', :action =>'index')
  r.default_routes
end


Merb::Config.use { |c|
  c[:environment]         = 'production',
  c[:framework]           = {},
  c[:log_level]           = 'debug',
  c[:use_mutex]           = false,
  c[:session_store]       = 'cookie',
  c[:session_id_key]      = '_session_id',
  c[:session_secret_key]  = 'bd81860e54a874b7f87173cb89e5b87211661349',
  c[:exception_details]   = true,
  c[:reload_classes]      = true,
  c[:reload_time]         = 0.5
}

dependency "merb_helpers"

Merb::BootLoader.after_app_loads do
  # require everything
  require "twitter"
  require "yaml"
  require "memcached"
  
  # set up my memcached server here...
  $cache = Memcached.new("127.0.0.1:11211")
end