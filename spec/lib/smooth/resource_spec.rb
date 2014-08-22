require "spec_helper"

describe "The Smooth Resource" do
  let(:api) { Smooth.current_api }
  let(:books) { api.resource("Books") }

  it "should reference its parent api" do
    expect(books.api).to be_present
  end

  it "should have a name" do
    expect(books.name).to eq("Books")
  end

  it "should have a like command class" do
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

  it "should generate a default serializer" do
    expect(BookSerializer < Smooth::Serializer).to equal(true)
  end

  it "should generate a default query context" do
    expect(BookQuery < Smooth::Query).to equal(true)
  end

end
