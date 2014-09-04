require "spec_helper"

describe "The Books Resource Routes" do
  let(:books) { Smooth("Books") }

  let(:session) do
    Rack::MockSession.new(books.api.sinatra)
  end

  let(:client) do
    Rack::Test::Session.new(session)
  end

  it "should make a request to the create command" do
    response = client.post("/books", title: "The Biography of Jon Soeder")
    body = JSON.parse(response.body) rescue {}

    expect(body["id"]).not_to be_nil
    expect(body["title"]).to eq("The Biography of Jon Soeder")
  end
end
