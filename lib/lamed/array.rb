class Array
  
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