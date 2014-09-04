require 'smooth/api/sinatra_adapter'

module Smooth
  class Api
    include Smooth::Documentation
    include Smooth::Api::SinatraAdapter

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

    def call(env)
      sinatra.call(env)
    end

    def as(current_user, &block)
      proxy = DslProxy.new(current_user, self)
      proxy.instance_eval(&block) if block_given?
      proxy
    end

    def lookup_current_user params, headers
      auth_strategy, key = authentication_strategy

      case
        when auth_strategy == :param && parts = params[key]
          id, passed_token = parts.split(':')
          user_class.find_for_smooth_api_request(id, passed_token)
        when auth_strategy == :header && parts = headers[key]
          id, passed_token = parts.split(':')
          user_class.find_for_smooth_api_request(id, passed_token)
        else
          user_class.anonymous_smooth_user(params, headers)
      end
    end

    def lookup_policy params, headers
      {}.to_mash
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

    def user_class user_klass=nil, &block
      @user_class = user_klass if user_klass.present?
      @user_class || User
      @user_class.class_eval(&block) if block_given?
      @user_class
    end

    def authentication_strategy option=nil, key=nil
      return @authentication_strategy || [:header, "X-AUTH-TOKEN"] if option.nil?

      if !option.nil?
        key = case
              when key.present?
                key
              when option.to_sym == :param
                :auth_token
              when option.to_sym == :header
                "X-AUTH-TOKEN"
              end
      end

      @authentication_strategy = [option, key]
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
        _policies[policy_name.to_sym] = obj
      end
    end

    def has_resource? resource_name
      resources.has_key?(resource_name.to_sym)
    end

    def resource resource_name, options={}, &block
      api_name = self.name

      existing = _resources[resource_name.to_s.downcase]

      if existing
        existing.apply_options(options) unless options.empty?
        existing.instance_eval(&block) if block_given?
        existing
      elsif options.empty? && !block_given?
        existing = nil

      elsif block_given?
        created = Smooth::Resource.new(resource_name, options, &block).tap do |obj|
          obj.api_name = api_name
        end

        _resources[resource_name.to_s.downcase] = created
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
