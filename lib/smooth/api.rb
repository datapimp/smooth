require 'smooth/dsl'

module Smooth
  class Api
    include Smooth::Documentation

    def self.default
      @default ||= Smooth::Api.new(:default)
    end

    attr_accessor :name,
                  :_version_config,
                  :_resources,
                  :_policies

    def initialize(name, options={})
      @name       = name.to_s
      @options    = options

      @_resources   = {}
      @_policies    = {}
    end

    def as(current_user, &block)
      proxy = DslProxy.new(current_user, self)
      proxy.instance_eval(&block) if block_given?
      proxy
    end

    def lookup_object_by path
      path = path.to_s
      resource_name, object_name = path.split(Smooth.config.object_path_separator)

      resource_object = resource(resource_name)

      case
      when object_name == "query" || object_name == "serializer"
        resource_object.fetch(object_name.to_sym, :default)
      when object_name.nil?
        resource_object
      else
        resource_object.fetch(:command, object_name)
      end
    end

    def resource_names
      _resources.keys
    end

    def interface_documentation
      resource_names.inject({}) do |memo, resource_name|
        memo.tap do
          memo[resource_name.to_s] = resource(resource_name).interface_documentation
        end
      end
    end

    def version config=nil
      @_version_config = config if config
      @_version_config
    end

    def policy policy_name, options={}, &block
      if obj = _policies[policy_name.to_sym]
        obj.apply_options(options) unless options.empty?
        obj.instance_eval(&block) if block_given?
        obj

      elsif options.empty? && !block_given?
        nil

      elsif block_given?
        obj = Smooth::Api::Policy.new(policy_name, options, &block)
        _resources[policy_name.to_sym] = obj
      end
    end

    def has_resource? resource_name
      resources.has_key?(resource_name.to_sym)
    end

    def resource resource_name, options={}, &block
      api_name = self.name

      if existing = _resources[resource_name.to_sym]
        existing.apply_options(options) unless options.empty?
        existing.instance_eval(&block) if block_given?
        existing

      elsif options.empty? && !block_given?
        existing = nil

      elsif block_given?
        created = Smooth::Resource.new(resource_name, options, &block).tap do |obj|
          obj.api_name = api_name
        end

        _resources[resource_name.to_sym] = created
      end
    end

  end

  class DslProxy
    def initialize(current_user, api)
      @current_user = current_user
      @api = api
    end

    def query resource_name, *args
      params = args.extract_options!
      query_name = args.first || :default
      @api.resource(resource_name).fetch(:query, query_name).as(@current_user).run(params)
    end

    def run_command resource_name, *args
      params = args.extract_options!
      command_name = args.first
      path = resource_name if command_name.nil?
      path = "#{ resource_name }.#{ command_name }" if command_name.present?
      @api.lookup_object_by(path).as(@current_user).run(params)
    end
  end
end

require 'smooth/api/tracking'
require 'smooth/api/policy'
