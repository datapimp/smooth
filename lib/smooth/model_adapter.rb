module Smooth
  module ModelAdapter
    def self.included base
      base.extend(ClassMethods)
    end

    def query(current_user, params={})
      self.class.smooth_resource.fetch(:query, :default)
        .as(current_user)
        .run(params)
    end

    module ClassMethods
      def acts_smooth options={}, &block
        @smooth_resource ||= begin
                               resource_name = to_s.split('::').last.to_s.pluralize
                               Smooth.resource(resource_name, model: self, &block)
                             end
      end

      # Because it depends how you feel.
      def acts_real_smooth(options={},&block)
        acts_smooth(options,&block)
      end

      def smooth_resource
        @smooth_resource || acts_as_smooth()
      end
    end
  end
end
