require "spec_helper"

describe "Smooth Configuration" do
  it "should be accessible from the module level" do
    expect(Smooth.config.class).to equal(Smooth::Configuration)
  end

  it "should give me the various base classes for smooth objects" do
    expect(Smooth.config.query_class).to equal(Smooth::Query)
    expect(Smooth.config.command_class).to equal(Smooth::Command)
  end

  it "should enable event tracking by default" do
    expect(Smooth.config.enable_event_tracking?).to eq(true)
  end
end
