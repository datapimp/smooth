module Smooth
  class Event < ActiveSupport::Notifications::Event

    def self.provider
      ActiveSupport::Notifications
    end

    def payload
      hash = super
      hash && hash.to_mash
    end

    module Adapter
      def track_event *args, &block
        Smooth::Event.provider.send(:instrument, *args)
      end

      def subscribe_to event_name, &block
        Smooth::Event.provider.subscribe(event_name) do |*args|
          block.call(Smooth::Event.new(*args), event_name)
        end
      end
    end

    extend Adapter
  end
end
