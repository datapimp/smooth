module Smooth
  class Api
    module Tracking
      def apis
        @@apis ||= {}
      end

      def fetch_api name, &block
        existing = apis[name.to_sym]

        if existing.nil? && block_given?
          existing = apis[name.to_sym] = block.call(name.to_sym)
        end

        existing
      end

      def current_api
        apis[current_api_name] ||= Smooth::Api.default()
      end

      def current_api_name= value
        @@current_api_name = value
      end

      def current_api_name
        (@@current_api_name || :default).to_sym
      end
    end
  end
end
