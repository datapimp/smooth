module Smooth
  class Configuration
    include Singleton

    cattr_accessor :query_class,
                   :command_class,
                   :serializer_class,
                   :object_path_separator,
                   :enable_events,
                   :definition_folders,
                   :eager_load_app_folders,
                   :active_record_config,
                   :models_path,
                   :schema_file,
                   :migrations_path,
                   :root,
                   :include_root_in_json,
                   :auth_token_column,
                   :enable_factories,
                   :async_provider,
                   :memory_store,
                   :embed_relationships_as

    @@query_class               = Smooth::Query
    @@command_class             = Smooth::Command
    @@serializer_class          = defined?(ApplicationSerializer) ? ApplicationSerializer : Smooth::Serializer
    @@enable_events             = true
    @@eager_load_app_folders    = true
    @@models_path               = 'app/models'
    @@object_path_separator     = '.'
    @@definition_folders        = %w(app/models app/apis app/queries app/commands app/serializers app/resources)
    @@include_root_in_json      = true
    @@enable_factories          = true

    @@active_record_config      = 'config/database.yml'
    @@schema_file               = 'db/schema.rb'
    @@migrations_path           = 'db/migrate'
    @@root                      = Dir.pwd
    @@auth_token_column         = :authentication_token
    @@async_provider            = Sidekiq::Worker if defined?(Sidekiq)
    @@memory_store              = Smooth.cache

    @@embed_relationships_as    = :ids

    def active_record
      return active_record_config if active_record_config.is_a?(Hash)
      file = root.join(active_record_config)
      fail 'The config file does not exist at ' + file.to_s unless file.exist?
      YAML.load(file.open).fetch(Smooth.env)
    end

    def enable_event_tracking?
      !!@@enable_events
    end

    def root
      Pathname(@@root)
    end

    def app_folder_paths
      Array(definition_folders).map { |f| root.join(f) }
    end

    def models_path
      root.join(@@models_path)
    end

    def method_missing(meth, *args, &block)
      if meth.to_s.match(/(\w+)\?$/)
        !!(send(Regexp.last_match[1], *args, &block)) if respond_to?(Regexp.last_match[1])
      else
        super
      end
    end

    def self.method_missing(meth, *args, &block)
      instance.send(meth, *args, &block)
    end
  end
end
