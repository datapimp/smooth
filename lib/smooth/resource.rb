require 'smooth/resource/templating'

module Smooth
  class Resource
    include Smooth::Documentation
    include Smooth::Resource::Templating

    attr_accessor :resource_name,
                  :api_name,
                  :model_class

    # These store the configuration values for the various
    # objects belonging to the resource.
    attr_reader  :_queries,
                 :_commands,
                 :_serializers,
                 :_routes,
                 :_examples,
                 :object_descriptions

    def initialize(resource_name, options={}, &block)
      @resource_name  = resource_name
      @options        = options

      @model_class    = options.fetch(:model, nil)

      @_serializers   = {}.to_mash
      @_commands      = {}.to_mash
      @_queries       = {}.to_mash
      @_routes        = {}.to_mash
      @_examples      = {}.to_mash

      @object_descriptions = {
        commands: {},
        queries: {},
        serializers: {},
        routes: {},
        examples: {}
      }

      @loaded         = false

      instance_eval(&block) if block_given?

      load!
    end

    def interface_documentation
      resource = self

      @interface ||= begin
                       base = {
                         routes: (router.interface_documentation() rescue {})
                       }

                       resource.object_descriptions.keys.inject(base) do |memo, type|
                         memo.tap do
                           bucket = memo[type] ||= {}
                           resource.send("available_#{ type }").each do |object_name|
                             docs = resource.expanded_documentation_for(type, object_name)
                             bucket[object_name] = docs
                           end
                         end
                       end
                     end.to_mash
    end

    def available_commands
      _commands.keys
    end

    def available_queries
      _queries.keys
    end

    def available_serializers
      _serializers.keys
    end

    # SHORT CIRCUIT
    def available_routes
      []
    end

    def available_examples
      _examples.keys
    end

    def model_class
      @model_class || (resource_name.singularize.constantize rescue nil)
    end

    def name
      resource_name
    end

    def fetch_config object_type, object_key
      source = send("_#{ object_type }s") rescue nil
      source = @_queries if object_type.to_sym == :query
      source && source.fetch(object_key.to_s.downcase.to_sym)
    end

    def fetch object_type, object_key
      source = instance_variable_get("@#{ object_type }s") rescue nil
      source = @queries if object_type.to_sym == :query
      source && source.fetch(object_key.to_s.downcase)
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

    def describe_object object_type, object_name, with_value={}
      bucket = self.documentation_for(object_type, object_name)

      with_value = {description: with_value} if with_value.is_a?(String)

      bucket[:description] = with_value.fetch(:description, with_value["description"])
      bucket[:description_args] = with_value.fetch(:args, [])
    end

    def documentation_for object_type, object_name
      self.object_descriptions[object_type.to_s.pluralize.to_sym][object_name.to_sym] ||= {}
    end

    def expanded_documentation_for object_type, object_name
      base = documentation_for(object_type, object_name)
      klass = object_class_for(object_type, object_name)

      base.merge!(class: klass.to_s, interface: klass && klass.interface_documentation)
    end

    def object_class_for object_type, object_name
      begin
        fetch(object_type.to_s.singularize.to_sym, object_name.to_sym)
      rescue => e
        binding.pry
      end
    end

    def serializer serializer_name="Default", *args, &block
      if args.empty? && !block_given? && exists = fetch(:serializer, serializer_name)
        return exists
      end

      options = args.extract_options!

      provided_description = options.fetch(:description, inline_description)

      describe_object(:serializer, serializer_name.downcase, provided_description) unless provided_description.empty?

      specified_class = args.first
      specified_class = specified_class.constantize if specified_class.is_a?(String)
      specified_class = nil if specified_class && !(specified_class <= Smooth.config.serializer_class)

      config = _serializers[serializer_name.downcase.to_sym] ||= Hashie::Mash.new(options: {}, name: serializer_name, blocks: [block].compact, class: specified_class)
      config.description = provided_description unless provided_description.nil?
    end

    def command command_name, *args, &block
      if args.empty? && !block_given? && exists = fetch(:command, command_name)
        return exists
      end

      options = args.extract_options!

      provided_description = options.fetch(:description, inline_description)

      describe_object(:command, command_name.downcase, provided_description) unless provided_description.empty?

      specified_class = args.first
      specified_class = (specified_class.constantize rescue nil) if specified_class.is_a?(String)
      specified_class = nil if specified_class && !(specified_class <= Smooth.config.command_class)

      config = _commands[command_name.to_sym] ||= Hashie::Mash.new(options: {}, name: command_name, blocks: [block].compact, class: specified_class)

      config.options.merge!(options)
      config.description = provided_description unless provided_description.nil?

      config
    end

    def query query_name="Default", *args, &block
      if args.empty? && !block_given? && exists = fetch(:query, query_name)
        return exists
      end

      options = args.extract_options!

      provided_description = options.fetch(:description, inline_description)

      describe_object(:query, query_name.downcase, provided_description) unless provided_description.empty?

      specified_class = args.first
      specified_class = (specified_class.constantize rescue nil) if specified_class.is_a?(String)
      specified_class = nil if specified_class && !(specified_class <= Smooth.config.query_class)

      config = _queries[query_name.downcase.to_sym] ||= Hashie::Mash.new(options: {}, name: query_name, blocks: [block].compact, class: specified_class)
      config.options.merge!(options)
      config.description = provided_description unless provided_description.nil?

      config
    end

    def routes options={}, &block
      return @router unless block_given?

      @router ||= Smooth::Resource::Router.new(self, options).tap do |router|
        router.instance_eval(&block)
        router.build_methods_table()
      end
    end

    def model(&block)
      model_class.instance_eval(&block)
    end

    def scope(*args, &block)
      model_class.send(:scope, *args, &block)
    end

    def router
      @router || routes()
    end

    def route_table
      router.route_table
    end

    def expand_routes(from_attributes={})
      router.expand_routes(from_attributes)
    end

    def examples options={}, &block
      if options.empty? && !block_given?
        return @examples
      end
    end

    def serializer_class reference=:default
      @serializers.fetch(reference, serializer_classes.first)
    end

    def query_class reference=:default
      @queries.fetch(reference, query_classes.first)
    end

    def serializer_classes
      @serializers && @serializers.values()
    end

    def query_classes
      @queries && @queries.values()
    end

    def command_classes
      @commands && @commands.values()
    end

    protected

    def configure_commands
      resource = self

      @commands = _commands.inject({}.to_mash) do |memo, p|
        ref, cfg = p
        memo[cfg.name.downcase] = Smooth::Command.configure(cfg, resource)
        memo
      end
    end

    def configure_serializers
      resource = self

      @serializers = _serializers.inject({}.to_mash) do |memo, p|
        memo.tap do
          ref, cfg = p
          serializer = memo[cfg.name.downcase] = Smooth::Serializer.configure(cfg, resource)

          serializer.return_ids_for_relationships! if Smooth.config.embed_relationships_as == :ids
        end
      end
    end

    def configure_queries
      resource = self

      @queries = _queries.inject({}.to_mash) do |memo, p|
        ref, cfg = p
        memo[cfg.name.downcase] = Smooth::Query.configure(cfg, resource)
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
require 'smooth/resource/router'
