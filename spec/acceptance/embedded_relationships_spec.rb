require "spec_helper"

describe "The Books Resource Routes" do
  let(:books) { Smooth("Books") }

  let(:session) do
    Rack::MockSession.new(books.api.sinatra)
  end

  let(:client) do
    Rack::Test::Session.new(session)
  end

  it "should fetch objects by ids" do

    book_ids = 3.times.map do |n|
      Book.create(title:"Book #{ Time.now.to_i }")
    end.slice(0,2).map(&:id).join(',')

    response =client.get("/books?ids=#{ book_ids }")
    json = JSON.parse(response.body) rescue {}

    binding.pry
    expect(json.length).to eq(2)
  end
end

