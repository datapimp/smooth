require 'singleton'

module Smooth
  class Configuration
    include Singleton

    cattr_accessor :query_class,
                   :command_class,
                   :serializer_class,
                   :object_path_separator,
                   :enable_events,
                   :definition_folders,
                   :eager_load_app_folders


    @@query_class               = Smooth::Query
    @@command_class             = Smooth::Command
    @@serializer_class          = defined?(ApplicationSerializer) ? ApplicationSerializer : Smooth::Serializer
    @@enable_events             = true
    @@eager_load_app_folders    = true
    @@object_path_separator     = '.'
    @@definition_folders        = %w{app/models app/resources app/queries app/commands app/serializers}

    def enable_event_tracking?
      !!@@enable_events
    end

    def root
      Smooth.root
    end

    def app_folder_paths
      Smooth.config.definition_folders.map {|f| root.join(f) }
    end

    def method_missing meth, *args, &block
      if meth.to_s.match(/(\w+)\?$/)
        !!(send($1, *args, &block)) if respond_to?($1)
      else
        super
      end
    end

    def self.method_missing meth, *args, &block
      instance.send(meth, *args, &block)
    end
  end
end
