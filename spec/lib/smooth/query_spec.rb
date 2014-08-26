require "spec_helper"

describe "The Smooth Query" do
  let(:query) { BookQuery }
  let(:user) { User.where(email:"jon@chicago.com",role:"user").first_or_create }

  before(:each) do
    Book.delete_all
  end

  it "should work when the class is defined directly, as well as when it is defined via the dsl" do
    expect(BookQuery.developer_defined_method).to eq(true)
    expect(BookQuery.new.inline_dsl_method).to eq(true)
  end

  it "should return some books" do
    Book.where(title:"Animal Farm").first_or_create()
    expect(query.run(title: "Animal Farm").count).to eq(1)
  end

  it "should query the books resource" do
    Book.where(title:"Animal Farm").first_or_create()
    expect(query.run(title: "Animal").count).to eq(1)
    expect(query.run(title: "1984").count).to eq(0)
  end

  it "should tell me info about the query interface" do
    description = query.interface_description.filters.year_published.description
    expect(description).to include('published')
  end

  it "should track query events" do
    bucket = []
    Smooth.events.on("query.book", bucket)
    query.as(user).run()
    expect(bucket).not_to be_empty
  end
end
