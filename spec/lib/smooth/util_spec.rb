require "spec_helper"

describe "The Smooth Utils" do
  it "should build a uri template parser" do
    expect(Smooth.util.uri_template("/api/:version/:resource_name")).to respond_to(:extract)
  end

  it "should extract vars from a url template" do
    template = Smooth.util.uri_template("/api/:version/:resource_name")
    vars = Smooth.util.extract_url_vars(template, "/api/v1/books")

    expect(vars[:version]).to eq("v1")
    expect(vars[:resource_name]).to eq("books")
  end

  it "should expand a uri template" do
    template = Smooth.util.uri_template("/api/:version/:resource_name")
    expanded = Smooth.util.expand_url_template(template, version: "v1", resource_name: "books")

    expect(expanded).to eq("/api/v1/books")
  end
end
