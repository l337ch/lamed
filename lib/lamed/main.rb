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
      use Rack::Lint
      use Rack::ShowExceptions
      use Rack::CommonLogger
      ObjectLoader.mapped_class.each_pair do |path, klass|
        map path do
          run klass.new
        end
      end
    end
    
  end
  
end