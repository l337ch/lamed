require 'rack'
require 'rack/builder'
require 'logger'

module Rack
  
  class Builder
    
    def run_apps
      Lamed::ObjectLoader.mapped_class.each_pair { |path, klass| map path do; run klass.new; end }
    end
    
  end
  
end

module Lamed
    
  require 'lib/lamed/initializer'
    
end