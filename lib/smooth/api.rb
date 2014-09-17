# The Smooth API
#
# An API is a collection of resources. A Resource is a collection of data models, and the API
# allows us to run queries against those data models or to run commands that express an intent
# to mutate the data models.
#
# An API provides different methods of authentication, and different policies for authorizations.
#
# An API is very easy to put a rest interface in front of, but can also work in other scenarios
# that speak JSON since the interface pretty well encapsulates the behavior.
module Smooth
  class Api

    # Being able to inspect an API and produce data suitable for generating interface
    # documentation, and automated tests, among other things, is a key feature of the gem.
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

    # The Smooth API is a gateway for the commands and queries
    # that can be run by users against its resources
    def lookup path
      lookup_object_by(path)
    end

    # The Smooth API Provides a Rack Compatible interface
    # so we can mount in sinatra or rails or whatever
    def call(env)
      sinatra.call(env)
    end

    # All Actions taken against the Smooth API are run 'as'
    # some current user. Example:
    #
    # Running a command:
    #
    #   api.as(jonathan).i_would_like_to
    #     .run_command("books.create").with(title:'Sup boo')
    #
    # Running a query
    #
    #   api.as(soederpop).i_would_like_to
    #     .query("books").with(subject:"how to...")
    #
    def as(current_user, &block)
      proxy = DslProxy.new(current_user, self)
      proxy.instance_eval(&block) if block_given?
      proxy
    end

    # The Smooth API generates a sinatra app to be able to
    # the various resources and run commands, queries, etc.
    def sinatra
      app = @sinatra_application_klass ||= Class.new(Sinatra::Base)

      @sinatra ||=  begin
                      _resources.each do |name, resource|
                        resource.router && resource.router.apply_to(app)
                      end

                      expose_interface_documentation_via(app)

                      app
                    end
    end

    def inspect
      "Smooth API: #{ name } Resources: #{ resource_names }"
    end

    # The API will rely on the configured authentication method
    # to determine who the user is.  Given some request params
    # and request headers
    def lookup_current_user params, headers
      auth_strategy, key = authentication_strategy

      case
        when auth_strategy == :param && parts = params[key]
          user_class.find_for_token_authentication(parts)
        when auth_strategy == :header && parts = headers[key]
          user_class.find_for_token_authentication(parts)
        else
          user_class.anonymous(params, headers)
      end
    end

    # The Policy will provide an ability file that we can
    # run a user though. The Policy can be overridden by the
    # resource, too.  A policy will pass an object path
    def lookup_policy params, headers
      {}.to_mash
      # TODO
      #
      # Implement:
      #
      # I think Smooth replaces too much of cancan to rely on it.
      #
      # I think the model where the resource inherits from the api, and
      # the api policy just white lists or black lists commands for given
      # user roles, will be sufficient
    end

    # The Smooth API provides an Asynchronous interface.
    def perform_async(object_path, payload={})
      worker.perform_async serialize_for_async(object_path, payload)
    end

    # Takes a request to do something and serializes the arguments in
    # the memory store. The request will be dispatched to the background job
    # handler and then resumed with the same arguments.
    #
    # Note: Rails Global ID will be a good replacement for this
    def serialize_for_async(object_path, payload)
      key = "#{ name }".parameterize + ":cmd:#{ String.random_token(16) }"

      request = {
        api: name,
        object_path: object_path,
        payload: payload
      }

      Smooth.config.memory_store.write(key, request)

      key
    end

    # Look up object by path. Used to route requests to
    # commands or queries.
    #
    # Example:
    #
    # lookup('books.create') #=> CreateBook
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

    def documentation_base
      {
        api_meta: {
          resource_names: resource_names
        }
      }
    end

    def interface_documentation
      resource_names.inject(documentation_base) do |memo, resource_name|
        memo.tap do
          memo[resource_name.to_s] = resource(resource_name).interface_documentation
        end
      end
    end

    def expose_interface_documentation_via(sinatra)
      api = self

      sinatra.send :get, "/interface" do
        api.interface_documentation.to_json
      end

      sinatra.send :get, "/interface/:resource_name" do
        docs = api.interface_documentation[params[:resource_name]]
        docs.to_json
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

    def worker &block
      worker_name = "#{ name }".camelize + "Worker"

      if worker_klass = Smooth::Api.const_get(worker_name) rescue nil
        @worker_klass = worker_klass
      else
        Object.const_get(worker_name, @worker_klass = Class.new(Smooth::Command::AsyncWorker))
      end

      @worker_klass.instance_eval(&block)

      @worker_klass
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

    def i_would_like_to
      self
    end

    def lemme
      self
    end

    def imll
      self
    end

    def query resource_name, *args
      params = args.extract_options!
      query_name = args.first || :default
      runner = @api.resource(resource_name).fetch(:query, query_name).as(@current_user)
      runner.async? ? perform_async(runner.object_path, params) : runner.run(params)
    end

    def run_command resource_name, *args
      params = args.extract_options!
      command_name = args.first
      path = resource_name if command_name.nil?
      path = "#{ resource_name }.#{ command_name }" if command_name.present?

      runner = @api.lookup_object_by(path).as(@current_user)
      runner.async? ? perform_async(runner.object_path, params) : runner.run(params)
    end

  end
end

