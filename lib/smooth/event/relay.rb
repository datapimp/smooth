# The Smooth::Event::Relay listens for events on any Smooth::Event notifications channel
# It takes the event, performs some optional processing on it, and then relays information
# about that event to some other service. For example, a websocket or another event tracking api.
module Smooth
  class Event < ActiveSupport::Notifications::Event
    class Relay
      attr_reader :event_name,
                  :options,
                  :system

      def initialize(event_name, options={})
        @event_name = event_name
        @options    = options
        @system     = options.fetch(:system, Smooth::Event)

        enable
      end

      def relay event, event_name=nil
        # IMPLEMENT IN YOUR OWN CLASS
        raise NotImplementedError
      end

      def process event, event_name=nil
        [event, event_name]
      end

      def enable
        @subscriber ||= system.subscribe_to(event_name, &method(:process_and_relay))
      end

      def process_and_relay(event, event_name=nil)
        event, event_name = process(event, event_name)
        relay(event, event_name)
      end
    end
  end
end
