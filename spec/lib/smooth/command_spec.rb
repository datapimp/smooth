require "spec_helper"

describe "The Smooth Command" do
  let(:command) { Smooth.current_api.resource("Books").fetch(:command, :like) }

  it "should allow for descriptions of the filters" do
    expect(command.input_descriptions[:like]).not_to be_blank
    expect(command.input_descriptions[:left_out]).to be_blank
  end
end
