require "spec_helper"

describe "The Smooth API Definition" do
  let(:api) { Smooth.current_api }

  it "should have a current api" do
    expect(api.name).to eq("My Application")
  end

  it "should retrieve an api instance by its name" do
    expect(Smooth.fetch_api("My Application").name).to eq("My Application")
  end

  it "should have a books resource" do
    resource = api.resource "Books"
    expect(resource).to be_a(Smooth::Resource)
  end

  it "should have a version" do
    expect(api.version).to equal(:v1)
  end
end

