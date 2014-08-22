module Smooth
  class Resource
    include Smooth::Documentation

    attr_accessor :resource_name,
                  :api_name

    # These store the configuration values for the various
    # objects belonging to the resource.
    attr_reader  :_queries,
                 :_commands,
                 :_serializers,
                 :_routes,
                 :_examples

    def initialize(resource_name, options={}, &block)
      @resource_name = resource_name
      @options = options

      @_serializers = {}.to_mash
      @_commands    = {}.to_mash
      @_queries     = {}.to_mash
      @_routes      = {}.to_mash
      @_examples    = {}.to_mash

      @loaded       = false

      instance_eval(&block) if block_given?

      load!
    end

    def name
      resource_name
    end

    def fetch_config object_type, object_key
      source = send("_#{ object_type }s") rescue nil
      source && source.fetch(object_key.to_sym)
    end

    def fetch object_type, object_key
      source = instance_variable_get("@#{ object_type }s") rescue nil
      source && source.fetch(object_key.to_sym)
    end

    def loaded?
      !!@loaded
    end

    def load!
      configure_commands
      configure_serializers
      configure_queries
      configure_routes
      configure_examples
    end

    def api
      Smooth.fetch_api(api_name || :default)
    end

    def apply_options *opts
      @options.send(:merge!, *opts)
    end

    def serializer serializer_name="Default", *args, &block
      if args.empty? && !block_given? && exists = fetch(:serializer, serializer_name)
        return exists
      end

      options = args.extract_options!

      description = options.fetch(:description) do
        args.first || inline_description
      end

      config = _serializers[serializer_name.to_sym] ||= Hashie::Mash.new(options: {}, name: serializer_name, blocks: [block].compact)
      config.description = description unless description.nil?

      config
    end

    def command command_name, *args, &block
      if args.empty? && !block_given? && exists = fetch(:command, command_name)
        return exists
      end

      options = args.extract_options!

      description = options.fetch(:description) do
        args.first || inline_description
      end

      config = _commands[command_name.to_sym] ||= Hashie::Mash.new(options: {}, name: command_name, blocks: [block].compact)

      config.options.merge!(options)
      config.description = description unless description.nil?

      config
    end

    def query query_name="Default", *args, &block
      if args.empty? && !block_given? && exists = fetch(:query, query_name)
        return exists
      end

      options = args.extract_options!

      description = options.fetch(:description) do
        args.first || inline_description
      end

      config = _queries[query_name.to_sym] ||= Hashie::Mash.new(options: {}, name: query_name, blocks: [block].compact)
      config.options.merge!(options)
      config.description = description unless description.nil?

      config
    end

    def routes &block
      return @routes if !block_given?
    end

    def examples options={}, &block
      if options.empty? && !block_given?
        return @examples
      end
    end

    protected

    def configure_commands
      resource = self

      @commands = _commands.inject({}.to_mash) do |memo, p|
        ref, cfg = p
        memo[cfg.name] = Smooth::Command.configure(cfg, resource)
        memo
      end
    end

    def configure_serializers
      resource = self

      @serializers = _serializers.inject({}.to_mash) do |memo, p|
        ref, cfg = p
        memo[cfg.name] = Smooth::Serializer.configure(cfg, resource)
        memo
      end
    end

    def configure_queries
      resource = self

      @queries = _queries.inject({}.to_mash) do |memo, p|
        ref, cfg = p
        memo[cfg.name] = Smooth::Query.configure(cfg, resource)
        memo
      end
    end

    def configure_routes
      @routes = {}
    end

    def configure_examples
      @examples = {}
    end
  end
end

require 'smooth/resource/tracking'
