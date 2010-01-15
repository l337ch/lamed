ROOT = ::File.join(::File.dirname(__FILE__), '..') unless defined?(ROOT)

module Lamed
  class ObjectLoader
    
    ORIG_OBJECT_CONSTANTS = Object.constants.freeze
    ROOT_EXT     = File.join(ROOT, "/ext")
    VIEW_PATH    = File.join(ROOT_EXT, "/views")
    file_pattern = "**/*.rb"
    
    FILE_FILTER = {
      :model      => File.join(ROOT_EXT, "/models", file_pattern),
      :controller => File.join(ROOT_EXT, "/controllers", file_pattern),
      :view       => File.join(ROOT_EXT, "/views", file_pattern)
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
        ext_subdir = subdir.split(ROOT_EXT + "/controllers")[1]
        camelized_ext_subdir = camelize_path ext_subdir if ext_subdir
        return camelized_ext_subdir
      end
    
      def create_object_from_camelized_path(camelized_ext_subdir)
        klass = Lamed::Controller
        if camelized_ext_subdir
          camelized_ext_subdir.each do |symbol|
            if klass.constants.include?(symbol)
              klass_prime = klass.const_get(symbol)
            else 
              klass_prime = klass.const_set(symbol, Module.new)
            end
            klass = klass_prime
          end
        end
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
        camelized_ext_subdir_dup = camelized_ext_subdir.nil? ? [] : camelized_ext_subdir.dup
        view_path = File.join(VIEW_PATH, uncamelize_path(camelized_ext_subdir_dup))
        return view_path
      end
    
      # Load new controller(s) into new klass(es) as defined by their path.
      # First load the files then build the class/modules(klass) from the path.
      # Then move the newly created objects into the newly built class.
      # Finally, remove the newly loaded objects from Object.
      # Change the +path=+ for the new controllers to the location of the mustache templates +VIEW_PATH+. 
      def load_controller_into_new_class(subdir, file_name)
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
      
      def load_controller_object
        get_files(:controller)
        map_file_to_subdir
        @mapped_file.each_pair { |subdir, file_name| load_controller_into_new_class(subdir, file_name) }
      end
      
      # Load model(s)
      def load_model_object
        orig_object_constants = Object.constants.dup
        klass = Lamed::Model
        get_files(:model)
        @paths.each { |f| load f }
        (Object.constants - orig_object_constants).each do |o|
          o_klass = Object.const_get(o)
          klass.const_set(o, o_klass)
          Object.instance_eval { remove_const o }
        end
      end    
    end
  end
end