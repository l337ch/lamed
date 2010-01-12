ROOT = ::File.join(::File.dirname(__FILE__), '..') unless defined?(ROOT)

module Lamed
    
  class ObjectLoader
    
    class << self
      
      include Lamed::Helper
      extend Lamed::Helper
      
      # Load objects in this order:
      #  Libraries - Lib
      #  Records or models - Record
      #  Controllers or apps - Controller
      
      ORIG_OBJECT_CONSTANTS = Object.constants.freeze
      ROOT_EXT     = File.join(ROOT, "/ext")
      VIEW_PATH    = File.join(ROOT_EXT, "/view")
      FILE_PATTERN = "**/*.rb"
      
      FILE_FILTER = {
        :record     => File.join(ROOT_EXT, "/record", FILE_PATTERN),
        :controller => File.join(ROOT_EXT, "/controller", FILE_PATTERN),
        :view       => File.join(ROOT_EXT, "/view", FILE_PATTERN)
      }
    
      def get_files(type)
        @paths = Dir.glob(FILE_FILTER[type])
      end
    
      def map_file_to_subdir
        @mapped_file = Hash.new
        @paths.each { |path|
          path_parts = File.split(path)
          dir = path_parts[0]
          file_name = path_parts[1]
          @mapped_file[dir] = @mapped_file[dir].nil? ? [file_name] : @mapped_file[dir] << file_name
        }
        @mapped_file
      end
    
      def camelize_ext_subdir(subdir)
        ext_subdir = subdir.split(ROOT_EXT)[1]
        camelized_ext_subdir = camelize_path ext_subdir
        return camelized_ext_subdir
      end
    
      def create_object_from_camelized_path(camelized_ext_subdir)
        klass = Lamed
        camelized_ext_subdir.each { |symbol|
          if klass.constants.include?(symbol)
            klass_prime = klass.const_get(symbol)
          else 
            klass_prime = klass.const_set(symbol, Module.new)
          end
          klass = klass_prime
        }
        return klass
      end
    
      def load_new_object(subdir, file_name)
        file_name.each { |f|
          file = File.join(subdir, f)
          load file
        }
        return nil
      end
    
      def create_view_path(camelized_ext_subdir)
        camelized_ext_subdir_prime = camelized_ext_subdir.dup; camelized_ext_subdir_prime.delete_at(0)
        camelized_ext_subdir_prime.unshift(:View)
        view_path = File.join(ROOT_EXT, uncamelize_path(camelized_ext_subdir_prime))
        return view_path
      end
    
      # Load new object(s) into new klass(es) as defined by their path.
      # First load the files then build the class/modules(klass) from the path.
      # Then move the newly created objects into the newly built klass.
      # Finally, remove the newly loaded objects from Object.
      # Change the path= for controllers to the location of the mustache templates. 
      def load_new_object_into_klass(subdir, file_name)
        orig_object_constants = Object.constants.dup
        load_new_object(subdir, file_name)
        camelized_ext_subdir = camelize_ext_subdir(subdir)
        klass = create_object_from_camelized_path(camelized_ext_subdir)
        view_path = create_view_path(camelized_ext_subdir)
        (Object.constants - orig_object_constants).each { |o|
          o_klass = Object.const_get(o)
          # Change path to mustache path location if it has the path method (Check for a Controller object)
          o_klass.path = create_view_path(camelized_ext_subdir) if o_klass.respond_to?('path')
          klass.const_set(o, o_klass)
          Object.instance_eval { remove_const o } 
        }
      end
      
      def load_new_objects(type)
        get_files(type)
        map_file_to_subdir
        @mapped_file.each_pair { |subdir, file_name| load_new_object_into_klass(subdir, file_name) }
      end
    
    end
    
  end
end