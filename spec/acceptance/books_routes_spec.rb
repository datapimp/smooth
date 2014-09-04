require "spec_helper"

describe "The Books Resource Routes" do
  let(:books) { Smooth("Books") }

  let(:session) do
    Rack::MockSession.new(books.api.sinatra)
  end

  let(:client) do
    Rack::Test::Session.new(session)
  end

  it "should make a request to the show action" do
    book = Book.create(title:"Cristian The LionHeart")
    response = client.get("/books/#{ book.id }")
  end

  it "should make a request to the books query" do
    Book.create(title:"Luca The Coming Champ", year_published: 1895)
    response = client.get("/books", title: "Luca")
    json = JSON.parse(response.body)
  end

  it "should make a request to the create command" do
    response = client.post("/books", title: "The Biography of Jon Soeder")
    json = JSON.parse(response.body) rescue {}

    body = json.fetch("book")

    expect(body).to have_key("author")
    expect(body["id"]).not_to be_nil
    expect(body["title"]).to eq("The Biography of Jon Soeder")
  end
end
