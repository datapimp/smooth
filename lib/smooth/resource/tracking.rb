module Smooth
  class Resource
    module Tracking
      def resources
        @@resources ||= {}
      end

      def current_resource= resource_object
        @current_resource = resource_object.identifier
      end

      def current_resource
        resources[@current_resource]
      end
    end
  end
end
