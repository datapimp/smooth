require "spec_helper"

describe "The Smooth Router" do
  let(:books) { Smooth("Books") }
  let(:router) { books.router }

  it "should have descriptions of the routes" do
    expect(router.descriptions).not_to be_empty
  end

  it "should apply the routes to a sinatra app" do
    expect(router.methods_table).to be_present
  end
end
