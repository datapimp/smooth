require "spec_helper"

describe "The Smooth Event Tracking API" do
  let(:events) { Smooth::Event }

  it "should use the instrumentation system to implement a little pub sub" do
    bucket = []

    events.subscribe_to "test.smooth" do |event|
      bucket << event
    end

    needle = rand(46**8).to_s(36)
    events.track_event 'test.smooth', line: "what up #{ needle }?"

    got_event = bucket.any? {|e| e.payload.line.include?(needle) }

    expect(got_event).to equal(true)
  end
end
