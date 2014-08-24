require "smooth/event/relay"
require "smooth/event/proxy"

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

      def subscribe_to event_name, aggregator=nil, &block
        Smooth::Event.provider.subscribe(event_name) do |*args|
          event = Smooth::Event.new(*args)
          aggregator << event if aggregator.respond_to?(:<<)
          block.call(event, event_name) if block.respond_to?(:call)
        end
      end
    end

    extend Adapter
  end
end
