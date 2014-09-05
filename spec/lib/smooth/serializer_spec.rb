require "spec_helper"

describe "The Smooth Serializer" do
  let(:books) { Smooth.current_api.resource("Books") }
  let(:serializer) { books.fetch(:serializer, "Default") }

  it "should configure the serializer" do
    expect(serializer.schema_attributes).not_to be_empty
  end

  it "should relate to the book model" do
    expect(Book.active_model_serializer).to equal(serializer)
    expect(serializer.model_class).to equal(Book)
  end

  it "should relate to the books resource" do
    expect(serializer.parent_resource).to equal(books)
  end

  it "should relate to the api" do
    expect(serializer.parent_api).to equal(books.api)
  end

  it "should have documentation for its attributes" do
    expect(serializer.documentation_for_attribute(:title).description).not_to be_blank
  end

  it "should have documentation for its relationships" do
    expect(serializer.documentation_for_association(:author).description).not_to be_blank
  end

  it "should have documentation for its computed properties" do
    expect(serializer.documentation_for_attribute(:computed_property).description).not_to be_blank
  end

end
