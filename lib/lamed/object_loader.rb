ROOT = ::File.join(::File.dirname(__FILE__), '..') unless defined?(ROOT)

module Lamed
    
  class ObjectLoader < Rack::Builder
    
    ORIG_OBJECT_CONSTANTS = Object.constants.freeze
    ROOT_EXT     = File.join(ROOT, "/ext")
    VIEW_PATH    = File.join(ROOT_EXT, "/view")
    FILE_PATTERN = "**/*.rb"
    
    FILE_FILTER = {
      :model      => File.join(ROOT_EXT, "/model", FILE_PATTERN),
      :controller => File.join(ROOT_EXT, "/controller", FILE_PATTERN),
      :view       => File.join(ROOT_EXT, "/view", FILE_PATTERN)
    }
    
    APP = Rack::Builder.new {
      use Rack::CommonLogger
      use Rack::ShowExceptions
      }
      
    class << self
      
      include Lamed
      include Helper
      extend Helper
      
      attr_reader :mapped_class
      
      # Load objects in this order:
      #  Libraries - Lib
      #  Records or models - Model
      #  Controllers or apps - Controller
        
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
        (Object.constants - orig_object_constants).each do |o|
          o_klass = Object.const_get(o)
          # Change path to mustache path location if it has the path method (Check for a Controller object)
          o_klass.path = create_view_path(camelized_ext_subdir) if o_klass.respond_to?(:path)
          klass.const_set(o, o_klass)
          Object.instance_eval { remove_const o }
          complete_klass_str = klass.to_s + "::" + o_klass.to_s
          map_new_class(complete_klass_str) if o_klass.respond_to?(:path)
        end
      end
      
      # Create a new map for the Controller using Rack::Builder map      
      def map_new_class(klass_str)
        path_prime = File.join(klass_str.split('::').collect { |s| uncamelize_string s })
        path = path_prime.split('/controller').last
        map_class_to_path(path, klass_str)
      end
      
      def map_class_to_path(path, klass_str)
        @mapped_class = Hash.new unless defined?(@mapped_class)
        @mapped_class[path] = eval(klass_str)
      end
      
      def load_new_objects(type)
        get_files(type)
        map_file_to_subdir
        @mapped_file.each_pair { |subdir, file_name| load_new_object_into_klass(subdir, file_name) }
      end
    
    end
    
  end
end