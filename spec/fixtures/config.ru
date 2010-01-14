lame_path = ::File.expand_path(::File.dirname(__FILE__)) + "/../../"
$LOAD_PATH.unshift(lame_path) unless $LOAD_PATH.include?(lame_path)
::ROOT = ::File.expand_path(::File.dirname(__FILE__)) unless defined?(::ROOT)

require 'lib/lamed'

# Don't remove this unless you want to manually map HTTP['PATH_INFO'] to your controllers.
run_apps

# Add your custom url mappings here
# map "/hello" do
#   run HelloWorld.new 
# end