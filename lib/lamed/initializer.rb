require 'yaml'
require 'logger'
require 'optparse'
require 'memcached'
require 'cgi'
require 'lib/lamed/helper'
require 'lib/lamed/object_loader'

module Lamed
  
  
  # Build configurations from yaml files  
  if defined?(ROOT)
    OPTIONS = {
      :env      => (ENV['RACK_ENV'] || "development").to_sym,
      :config   => ROOT + '/conf/',
      :log_path => ROOT + '/logs',
      :verbose  => false
    }  
    
    if File.exists?(File.join(ROOT,'/conf/config.yml'))
      SYS_OPTIONS = YAML.load_file(OPTIONS[:config] + "config.yml")[OPTIONS[:env].to_s].inject({}) {|h,(k,v)| h[k.intern] = v; h}
    end
    if File.exists?(ROOT + '/conf/database.yml')
    DB_OPTIONS = YAML.load_file(OPTIONS[:config] + "database.yml")[OPTIONS[:env].to_s].inject({}) {|h,(k,v)| h[k.intern] = v; h}
    end    
    if defined?(SYS_OPTIONS)
      @sys_options = SYS_OPTIONS 
      log_path =@sys_options[:logs] || OPTIONS[:log_path]
      OPTIONS[:rotate] = !@sys_options.nil? ? @sys_options[:rotate] : nil
      OPTIONS[:log] = File.join(log_path, OPTIONS[:env].to_s ,".log")
    end
  end
  
  class << self

    # Set up logging
    def initialize_logger
      if defined?(SYS_OPTIONS)
        logs = Logger.new(@log_path, OPTIONS[:rotate])
        case OPTIONS[:env]
        when :development
          logs.level = Logger::DEBUG
        when :test
          logs.level = Logger::DEBUG
        when :staging
          logs.level = Logger::DEBUG
        when :production
          logs.level = Logger::WARN
        end
      else
        logs = Logger.new(STDERR)
      end
      puts "The log path does not exist or is not writable.  Log messages will be sent to STANDARD ERROR"
      @logger = logs
      logs.warn("Logging level is set to #{logs.level}")
      return @logger
    end
    
    if defined?(ROOT)
      require 'lib/lamed/record'
      require 'lib/lamed/lib'
    end

    def logger
      @logger
    end
    
    def load_lib
      #Dir[LAME_ROOT + '/lib/*.rb'].each {|d| require d}
      lib = LoadObjects.new(ROOT, :lib)
      lib.build_path_hash
      lib.build_objects
    end
    
    def load_controller
      ObjectLoader.load_new_objects(:controller)
    end
    
    def load_record
      ObjectLoader.load_new_objects(:record)
    end
    
  end
  
  if defined?(SYS_OPTIONS)
    load_record
    require 'lib/lamed/controller'
    load_controller
  end
  initialize_logger

end
