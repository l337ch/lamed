class String
    
    def camel_string(str = self)
      # Used to camel case a string split by _
      name = str.split("_").map {|s| s.capitalize }.join
      return name
    end
    
    def camel_string!
      # Used to camel case a string split by _
      camel_string = self.split("_").map {|s| s.capitalize }.join
      self.gsub!(/^.*$/, camel_string)
      return nil
    end
    
    def camel_path
      # Used to camel case a string or path split by /
      path_array = self.split("/").collect {|a| self.camel_string(a).intern}
      return path_array
    end
    
    def mysql_time  
      # Convert strings into a usable MySQL time object.  
      string[/(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)/]
      year = $1.to_i; month = $2.to_i; day = $3.to_i; hour = $4.to_i; min = $5.to_i; sec = $6.to_i
      new_time = Time.local(year,month,day,hour,min,sec)
      return new_time
    end
    
    def uncamel_string(str = self)
      uncamel_string = (self.split('').collect {|c| c = c.upcase! == nil ? '_' + c.downcase : c.downcase}).join
      uncamel_string.slice!(0) if uncamel_string[0] == '_'
      return uncamel_string
    end
    
    def uncamel_string!
      uncamel_string = (self.split('').collect {|c| c = c.upcase! == nil ? '_' + c.downcase : c.downcase}).join
      uncamel_string.slice!(0) if uncamel_string[0] == '_'
      self.gsub!(/^.*$/, uncamel_string)
      return nil
    end
    
    def uncamel_path(camel_path)
    end
      
end