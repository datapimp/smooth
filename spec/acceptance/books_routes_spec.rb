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
    json = JSON.parse(response.body) rescue {}
    book = json.fetch("book")

    expect(response.status).to eq(200)
    expect(book["title"]).to eq("Cristian The LionHeart")
  end

  it "should make a request to the books query" do
    Book.create(title:"Luca The Coming Champ", year_published: 1895)
    response = client.get("/books", title: "Luca")
    json = JSON.parse(response.body) rescue {}

    expect(json).not_to be_empty
    expect(response.status).to eq(200)
  end

  it "should make a request to the create command" do
    response = client.post("/books", title: "The Biography of Jon Soeder")

    json = JSON.parse(response.body) rescue {}

    book = json.fetch("book")

    expect(response.status).to eq(200)
    expect(book).to have_key("author_id")
    expect(book["id"]).not_to be_nil
    expect(book["title"]).to eq("The Biography of Jon Soeder")
  end

  it "should return errors if i don't include the right params" do
    response = client.post("/books")
    expect(response.status).not_to eq(200)
  end
end
