lib_path = File.expand_path(File.dirname(__FILE__)) + "/../"
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

::LAME_ROOT = ::File.expand_path(::File.dirname(__FILE__)) unless defined?(::LAME_ROOT)

require 'lib/lamed/main'

module Lamed
  
  VERSION = '0.4.6'
  
end