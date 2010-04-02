require 'mysql'
require 'dm-core'
require 'dm-types'
require 'dm-aggregates'
#require 'lib/lamed/redis'
require 'redis'

module Lamed
  
  module Model
        
    #LAME_ROOT = ::LAME_ROOT unless defined?(LAME_ROOT)
  
  end
  
  # Support for DataMapper
  class DM
    
    #include DataMapper::Resource
    include DataMapper
    
    # Setup the database connection using DataMapper
    def initialize(params = {})
      @host          = params[:host]      || 'localhost'
      @port          = (params[:port]     || 3306).to_i
      @user          = params[:username]  || 'root'
      @password      = params[:password]  || 'pwd'
      @database      = params[:database]  || 'ithingy'
      @adapter       = params[:adapter]   || 'mysql'
      self.connect
    end
    
    def connect(params = {})
      DataMapper.setup(:default, "#{@adapter}://#{@user}:#{@password}@#{@host}:#{@port}/#{@database}")
    end
  end
  
  class MySQL < Mysql

    attr_reader :status, :db_conn, :db_conn_read, :params

    def initialize(params = {})
      @params        = params
      @host          = params[:host]      || '127.0.0.1'
      @port          = (params[:port]     || 3306).to_i
      @user          = params[:username]  || 'root'
      @password      = params[:password]  || 'pwd'
      @database      = params[:database]
      @read_host     = params[:read_host]
      @read_username = params[:read_user]
      @read_password = params[:read_password]
      @read_database = params[:read_password]
      @read_port     = params[:read_port]
      self.connect
    end

    def connect
      $db_conn = Mysql.real_connect(@host, @user, @password, @database, @port)
      # Check to make sure there is a read db in the configs
      if @read_host
        $db_conn_read = Mysql.real_connect(@read_host, @read_username, @read_password, @read_database, @read_port)
      else
        $db_conn_read = $db_conn
      end
    end

    def self.query(query_string)
      n = 0							# track how many times the system had to reconnect to the db
      begin
        # Test to see if the query starts with a select which would mean it was a read query
        if query_string.split[0].upcase == "SELECT"
          res = $db_conn_read.query(query_string)
        else
          res = $db_conn.query(query_string)
        end
      rescue Mysql::Error => e
        case e.to_s
          when 'MySQL server has gone away'
            MySQL.new($DB_OPTIONS)
            n += 1
            retry
          when 'Lost connection to MySQL server during query'
            MySQL.new($DB_OPTIONS) 
            n += 1
            retry
          else
            # Don't know what to do because of an unknown error so to play it safe we'll just break instead looping endlessly.
            raise "ERROR: #{e.to_s} Not sure what this error is from #{@host}."
        end
      end
      return res
    end
  end
end

class Redis
  
  # Adding namespace or prefix keys to redis SET and GET request much like memcache.
  
  $SYS_OPTIONS = {} unless defined?($SYS_OPTIONS)
  
  REDIS_OPTIONS = {
    :host    =>  $SYS_OPTIONS[:redis_host]     || '127.0.0.1' ,
    :port    => ($SYS_OPTIONS[:redis_port]    || 6379).to_i,
    :db      => ($SYS_OPTIONS[:redis_db]      || 0).to_i,
    :timeout => ($SYS_OPTIONS[:redis_timeout] || 5).to_i,
  }
  
  def initialize(host, opts={})
    @host    = host           || REDIS_OPTIONS[:host]
    @port    = opts[:port]    || REDIS_OPTIONS[:port]
    @db      = opts[:db]      || REDIS_OPTIONS[:db]
    @timeout = opts[:timeout] || REDIS_OPTIONS[:timeout]
    $debug   = opts[:debug]
    connect_to_server
  end
  
  def load
  end
  
end