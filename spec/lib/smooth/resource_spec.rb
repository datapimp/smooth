require "spec_helper"

describe "The Smooth Resource" do
  let(:api) { Smooth.current_api }
  let(:books) { api.resource("Books") }

  it "should define scopes on its model" do
    api.resource("Books") do
      model do
        scope :model_defined_scope, -> { where("id is whatup") }
      end

      scope :resource_defined_scope, -> { where("id is you know") }
    end

    expect(Book).to respond_to(:model_defined_scope)
    expect(Book).to respond_to(:resource_defined_scope)
  end

  it "should reference its parent api" do
    expect(books.api).to be_present
  end

  it "should have a name" do
    expect(books.name).to eq("Books")
  end

  it "should know the route patterns" do
    expect(books.router.patterns).not_to be_empty
  end

  it "should have an arbitrary defined command class" do
    command = books.fetch(:command, :like)
    expect(command).to respond_to(:run)
  end

  it "should have an update command class" do
    command = books.fetch(:command, :update)
    expect(command).to respond_to(:run)
  end

  it "should have a create command class" do
    command = books.fetch(:command, :create)
    expect(command).to respond_to(:run)
  end

  it "should return a reference to the serializer class" do
    expect(books.serializer_class).to equal(BookSerializer)
  end

  it "should return a reference to the query class" do
    expect(books.query_class).to equal(BookQuery)
  end

  it "should generate a default serializer" do
    expect(BookSerializer < Smooth::Serializer).to equal(true)
  end

  it "should generate a default query context" do
    expect(BookQuery < Smooth::Query).to equal(true)
  end

end
