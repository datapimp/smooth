require "spec_helper"

describe "The Smooth Command" do
  let(:command) { Smooth.current_api.resource("Books").fetch(:command, :like) }

  it "should allow for descriptions of the filters" do
    expect(command.input_descriptions[:like]).not_to be_blank
    expect(command.input_descriptions[:left_out]).to be_blank
  end

  it "should know the resource name" do
    expect(command.resource_name).to eq("Books")
  end

  it "should know the command action" do
    expect(command.command_action).to eq("like")
  end

  it "should know the event namespace" do
    expect(command.event_namespace).to eq("like.book")
  end

  describe "Event Tracking Integration" do
    it "should track events" do
      bucket = []

      Smooth.subscribe_to(/like.book/)  do |event|
        bucket << event
      end

      command.run()

      expect(bucket).not_to be_empty
    end
  end
end
