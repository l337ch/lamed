require 'rack'
require 'rack/builder'
require 'logger'

module Lamed
    
  require 'lib/lamed/initializer'
    
end

module Rack
  
  class Builder
    
    include Lamed
    
    def run_apps
      ObjectLoader.mapped_class.each_pair { |path, klass| map path do; run klass.new; end }
    end
    
  end
  
end