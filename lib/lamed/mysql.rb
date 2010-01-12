require 'mysql'

class MySQL 

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