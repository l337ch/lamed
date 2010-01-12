require 'lamed/string'

module Lamedd
  
  class LoadObjects
    
    attr_reader :working_path, :work_path_array, :path_hash

    OBJECT_PATHS = {
      :controller => '/ext/controller',
      :record     => '/ext/record',
      :lib        => '/lib',
      :view       => '/ext/view'
    }
    
    OBJECT_TYPES = {
      :controller => '*.rb',
      :record     => '*.rb',
      :lib        => '*.rb',
      :view       => '*.{rb,haml,erb,html}'       # not being used anymore - using Mustache for views
    }
    
    OBJECT_CONST = {
      :controller => :Controller,
      :record     => :Record,
      :view       => :View,
      :lib        => :Lib
    }
    
    def initialize(path, object_type)
      # Find the working path from the whole path given
      # Empty directories will not get loaded
      @object_type = object_type
      type_pattern = File.join("**", OBJECT_TYPES[object_type])
      current_dir = Dir.pwd
      #@object_class = Lamed.const_set(OBJECT_CONST[object_type], Module.new)
      @object_class = Lamed.const_get(OBJECT_CONST[object_type])
      @working_path = path + OBJECT_PATHS[object_type]
      Dir.chdir(@working_path)
      @work_path_array = Dir.glob(type_pattern) 
      # Find all the objects in the work_path
      Dir.chdir(current_dir)
    end
    
    def build_path_hash
      # Build a hash with the files mapped to the paths
      @path_hash = Hash.new(Array.new)
      work_path_array = @work_path_array
      work_path_array.each do |path|
        if File.file?(@working_path + "/" + path)
          file = File.basename(path)
          chomp_path = path.chomp!("/" + file)
          if chomp_path.nil?
            # This is a file and there is now path
            @path_hash["top_level"] += [file]
          else
            @path_hash[chomp_path] += [file]
          end
        end
      end
    end
           
    def build_objects
      # Build objects from path
      path_hash = @path_hash
      begin
        path_hash.each_pair { |k,v|
          klass = @object_class
          # Take the path and make syms
          sym_path = k.camel_path
          # Make each sym in the path into objects if they don't exist
          sym_path.each { |s|
            if klass.constants.include?(s)
              # This object already exists
              new_klass = klass.const_get("#{s}")
            elsif s == :TopLevel      #this is a top level object
              new_klass = @object_class
            else
              new_klass = klass.const_set(s, Module.new)
            end
            klass = new_klass
            # What objects exist now
          }
          v.each { |c|
            orig_objects = Object.constants
            dir = k == "top_level" ? "" : k
            load @working_path + "/" + dir + "/" + c
            new_objects = Object.constants - orig_objects
            new_objects.each { |o|
              new_klass = Object.const_get("#{o}")
              klass.const_set("#{o}", new_klass)
              self.set_self_path(klass, new_klass) if @object_type == :controller
              begin
                Object.instance_eval{ remove_const o }
              rescue NameError
                # Symbol is inherited
              end
            }
          }
        }
      rescue StandardError => e 
        raise e
      end
    end
    
    def get_path_symbols
      sub_dir_arr = @work_path.split("/")
      sub_dir = sub_dir_arr
      sub_dir_hash = sub_dir.inject({}) {|h,(k,v)| h[k.camel_string.intern] = k.camel_string if File.extname(k) != '.rb';h}
      return sub_dir_hash
    end
    
    def instantiate_class(path, extname)
      # Given the path, load the class
      pre_path = pre.split("/")
      Dir[path + '/*'].each do |d|
        sub_dir_hash = get_modules(d, pre_arr)
        nmodule = build_modules(sub_dir_hash)
        @sub_dir_found = load_class(d, nmodule, extname)
      end
      dir = @sub_dir_found
      @sub_dir_found = nil
      return dir      
    end
    
    def set_self_path(klass, new_klass)
      # Changes the class path to where it's view template is.
       klass_array = klass.to_s.split('::')
       klass_array.slice!(0)
       klass_array.collect! {|a| a.uncamel_string}
       new_klass.path = ::ROOT + '/ext/view/' + klass_array.join('/')
    end     

  end

end