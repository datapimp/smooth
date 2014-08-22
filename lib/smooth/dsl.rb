module Smooth
  module Dsl
    # Creates or opens an API definition
    def api name, *args, &block
      Smooth.current_api_name = name

      instance = Smooth.fetch_api(name) do |key|
        options = args.dup.extract_options!

        Smooth::Api.new(name, options).tap do |obj|
          obj.instance_eval(&block) if block_given?
        end
      end

      instance
    end

    # Creates or opens a resource definition
    def resource name, *args, &block
      options = args.extract_options!

      api = case
        when options[:api].is_a?(Symbol) || options[:api].is_a?(String)
          Smooth.fetch_api(options[:api])
        when options[:api].is_a?(Smooth::Api)
          options[:api]
        else
          Smooth.current_api
      end

      api.resource(name, options, &block)
    end
  end
end

extend(Smooth::Dsl)
