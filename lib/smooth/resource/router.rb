module Smooth
  class Resource
    class Router

      attr_reader :resource,
                  :table,
                  :descriptions,
                  :rules

      def initialize(resource, options={})
        @resource = resource
        @table = {}
        @descriptions = {}
        @rules = []
      end

      def route_table
        @route_table ||= route_patterns_table.inject({}) do |memo, p|
          route_name, details = p
          memo[route_name] = details[:pattern]
          memo
        end
      end

      def expand_routes(from_attributes={})
        route_patterns_table.inject({}) do |memo, p|
          route_name, details = p
          memo[route_name] = Smooth.util.expand_url_template(details[:template], from_attributes)
          memo
        end
      end

      def route_patterns_table
        return @route_patterns_table if @route_patterns_table

        @route_patterns_table = rules.flatten.compact.inject({}) do |memo, rule|
          memo.tap do
            name = rule[:name]
            pattern = rule[:pattern]
            template = rule[:template]

            memo[name] = {
              pattern: pattern,
              template: template,
              variables: Array(template.variables)
            }
          end
        end
      end

      def patterns
        rules.flatten.compact.map {|r| r.fetch(:pattern) }
      end

      def uri_templates
        rules.flatten.compact.map {|r| r.fetch(:template) }
      end

      def apply_to(sinatra)
        router = self

        user_finder = resource.api.method(:lookup_current_user).to_proc
        policy_finder = resource.api.method(:lookup_policy).to_proc

        router.rules.each do |_|
          options, _ = _

          handler = methods_table.method(options[:name])

          sinatra.send options[:method], options[:pattern] do |*args|
            begin
              request = {
                headers: headers,
                params: params,
                user: user_finder.call(params, headers),
                policy: policy_finder.call(params, headers),
                args: args
              }
            rescue => exception
              halt 500, {}, { error: exception.message, backtrace: exception.backtrace, stage: "request" }.to_json
            end

            begin
              response = handler.call(request.to_mash)

              body response.body
              headers response.headers
              status response.status
            rescue => exception
              halt 500, {}, {error: exception.message, backtrace: exception.backtrace, stage: "response"}.to_json
            end
          end
        end
      end

      def build_methods_table
        router = self

        @methods_table_class = Class.new do

          k = self

          router.rules.each do |_|
            options, block = _
            method_name   = options.fetch(:name)
            k.send :define_method, method_name, (block ||router.lookup_handler_for(options[:method], options[:to]))
          end
        end
      end

      def counter
        @counter ||= 0
        @counter += 1
      end

      def methods_table
        @methods_table ||= (@methods_table_class || build_methods_table).new
      end

      def desc description, *args
        descriptions[:current] = description
      end

      Verbs = {
        :get => :get,
        :show => :get,
        :put => :put,
        :patch => :put,
        :create => :post,
        :delete => :delete,
        :destroy => :destroy,
        :options => :options,
        :post => :post
      }

      def method_missing meth, *args, &block
        if Verbs.keys.include?(meth.to_sym)
          pattern = args.shift
          define_route(meth, pattern, *args, &block)
        else
          super
        end
      end

      def define_route request_method, route_pattern, *args, &block
        request_method = Verbs.fetch(request_method.to_sym, :get)
        bucket = table[request_method] ||= {}
        options = args.extract_options!

        name = options.fetch(:as, "#{ request_method }_#{ counter }")

        describe_route(request_method, route_pattern)

        rules << bucket[route_pattern] = [
          options.merge(:name => name, :method => request_method, args: args, pattern: route_pattern, template: Smooth.util.uri_template(route_pattern)),
          block
        ]
      end

      def describe_route request_method, route_pattern
        documentation = descriptions[request_method] ||= {}

        if description = descriptions[:current]
          documentation[route_pattern] = description
          descriptions.delete(:current)
        end
      end

      # Allows for a configuration syntax like
      #
      # routes do
      #   get "/books", :to => :query
      # end
      #
      # the lookup_handler_for method will attempt to
      # discern which object is best suited to handle the
      # request based on the http verb and the signifier
      def lookup_handler_for(method, signifier)
        method = method.to_sym
        signifier = signifier.to_sym

        resource = self.resource

        case

        when method == :get && signifier == :query
          ->(req) { resource.fetch(:query, :default).respond_to_request(req) }

        when (method == :show || method == :get) && signifier == :show
          ->(req) { resource.fetch(:query, :default).respond_to_find_request(req) }

        when method == :get
          ->(req) { resource.fetch(:query, signifier).respond_to_request(req) }

        # Mutation Methods
        when method == :put || method == :post || method == :delete
          ->(req) { resource.fetch(:command, signifier).respond_to_request(req) }
        else
          ->(req) { Smooth::ErrorResponse.new("Unable to find matching route", req) }
        end
      end

    end
  end
end
