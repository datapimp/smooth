require "spec_helper"

describe "The Smooth Cache Adapter" do
  it "should delegate to rails caching system" do
    value = Smooth.cache.fetch(:key) { 2 }
    expect(value).to equal(1)
  end
end
