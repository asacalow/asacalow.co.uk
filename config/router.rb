Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  r.match('/').to(:controller => 'main', :action =>'index')
  r.default_routes
end