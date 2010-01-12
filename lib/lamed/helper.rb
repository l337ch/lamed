module Lamed
  
  module Helper
          
    # -=-=-=-= Hash Helper =-=-=-=-
    # Changes keys that are strings in symbols.  Goes two deep.
    def symbolize_hash_keys(hash = self)
      symbolize_value = ->(value) { value.inject({}) {|h,(k,v)| h[(k.intern rescue k) || key] = v;h } }
      hash.inject({}) do |options, (key, value)|
        value = Hash === value ? symbolize_value.call(value) : value
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
  
    # -=-=-=-= String Helper =-=-=-=-
    # Camel case a string with _ separator(s)
    def camelize_string(str)
      cameled_string = str.split("_").map {|s| s.capitalize }.join
      return cameled_string
    end
  
    # Camel case a string with / separator(s)
    def camelize_path(path)
      cameled_path = path.split("/").collect {|a| camelize_string(a).intern}
      cameled_path.delete_if { |s| s == :""}
      return cameled_path
    end
  
    def uncamelize_string(str)
      uncameled_string = (str.split('').collect {|c| c = c.upcase! == nil ? '_' + c.downcase : c.downcase}).join
      uncameled_string.slice!(0) if uncameled_string[0] == '_'
      return uncameled_string
    end
  
    def uncamelize_path(cameled_path)
      uncameled_path = cameled_path.collect { |p| uncamelize_string(p.to_s) }
      path = uncameled_path.join("/").insert(0, "/")
      return path
    end
    
    # Convert strings into a usable MySQL time object.
    def mysql_time(str)
      str[/(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)/]
      year = $1.to_i; month = $2.to_i; day = $3.to_i; hour = $4.to_i; min = $5.to_i; sec = $6.to_i
      new_time = Time.local(year,month,day,hour,min,sec)
      return new_time
    end
    
    # -=-=-=-=Array Helper =-=-=-=-
    def sorted_array(array = self)
      count_hash = array.inject({}) { |h,(k,v)| h[k] = 0 if h[k].nil?; h[k] += 1; h }
      sorted_array = count_hash.to_a.collect { |a|
          a.reverse
        }.sort.reverse.collect { |a|
          a.reverse
        }
      sorted_array.collect! { |a| a[0] }
      return sorted_array
    end

    def sorted_hash(array = self)
      count_hash = array.inject({}) { |h,(k,v)| h[k] = 0 if h[k].nil?; h[k] += 1; h }
      sorted_array = count_hash.to_a.collect { |a|
          a.reverse
        }.sort.reverse.collect { |a|
          a.reverse
        }
      sorted_group = sorted_array.inject ({}) { |h,(k,v)|
          h[k] = v
          h
        }
      return sorted_group
    end

    def sorted_weighted_hash(array = self)
      sorted_group = array.sorted_group
      size = sorted_group.length
      new_hash = Hash.new
      sorted_group.each_pair { |k,v|
        new_hash[k] = v.to_f/size.to_f
      }
      return new_hash
    end
    
  end
  
end