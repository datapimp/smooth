require "spec_helper"

class EventRelayTester < Smooth::Event::Relay
  class_attribute :bucket

  self.bucket = []

  def relay event, event_name=nil
    self.class.bucket << {event: event, event_name: event_name}
  end

  def process event, event_name=nil
    [event, "processed:#{event_name}"]
  end
end

describe "The Smooth Event Relay" do
  let(:events) { relay.system }
  let(:relay) { EventRelayTester.new('relayed.event') }

  it "should relay events" do
    bucket = relay.class.bucket
    events.track_event("relayed.event", val: "sup")
    expect(bucket).not_to be_empty
  end

  it "should process the event before it relays it" do
    bucket = relay.class.bucket
    events.track_event("relayed.event", val: "sup")
    success = bucket.map {|h| h[:event_name] }.any? {|s| s == 'processed:relayed.event' }
    expect(success).to eq(true)
  end
end
