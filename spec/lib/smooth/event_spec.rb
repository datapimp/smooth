require "spec_helper"

describe "The Smooth Event Tracking API" do
  let(:events) { Smooth::Event }

  it "should use the instrumentation system to implement a little pub sub dsl" do
    needle = rand(46**8).to_s(36)

    events.subscribe_to "test.smooth", (bucket=[])

    events.track_event 'test.smooth', val: needle

    got_event = bucket.any? {|e| e.payload.val.include?(needle) }

    expect(got_event).to equal(true)
  end
end
