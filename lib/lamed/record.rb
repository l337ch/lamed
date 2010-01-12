require 'lib/lamed/mysql'
require 'lib/lamed/redis'

module Lamed
  
  module Record
    
    #include Lamed
    
    LAME_ROOT = ::LAME_ROOT unless defined?(LAME_ROOT)
    
    if defined?($DB_OPTIONS)
      record.build_path_hash
      record.build_objects
    end

  
  end

end