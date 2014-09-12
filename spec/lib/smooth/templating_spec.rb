require "spec_helper"

describe "Resource Object Templates" do
  let(:books) { Smooth("Books") }

  it "should let me build templated book objects" do
    expect(books.build_from_template().title).to be_present
    expect(books.build_from_template(title:"Shit Homie").title).to eq("Shit Homie")
  end

  it "should let me create templated book objects" do
    expect(books.create_from_template().title).to be_present
    expect(books.create_from_template(title:"Shit Homie").title).to eq("Shit Homie")
  end

  it "should let me define custom templates" do
    expect(books.build_from_template(:ancient).year_published).to eq(1776)
  end

  it "should know if a template has been registered" do
    expect(books.template_registered?).to eq(true)
  end
end
