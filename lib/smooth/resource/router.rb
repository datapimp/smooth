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
              return {
                error: exception.message,
                stage: "request"
              }.to_json
            end

            response = begin
                         handler.call(request.to_mash)
                       rescue => exception
                         {
                           error: exception.message,
                           stage: "response"
                         }
                       end

            response.to_json
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
          options.merge(:name => name, :method => request_method, args: args, pattern: route_pattern),
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
          ->(req) { resource.fetch(:query, :default).handle_request(req) }
        when method == :show && signifier == :show
          ->(req) { resource.fetch(:query, :default).handle_request(req, show: true) }
        when method == :get
          ->(req) { resource.fetch(:query, signifier).handle_request(req) }
        when method == :put || method == :post || method == :delete && [:create,:update,:destroy].include?(signifier)
          ->(req) { resource.fetch(:command, signifier).handle_request(req) }
        when method == :put || method == :post || method == :delete
          ->(req) { resource.fetch(:command, signifier).handle_request(req) }
        else
          -> { {status: "Not Found" }.to_json }
        end
      end

    end
  end
end
