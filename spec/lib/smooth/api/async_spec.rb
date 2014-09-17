require "spec_helper"

describe "Smooth Command Background Job Handling" do
  let(:api) { Smooth() }

  it "should serialize a command call and restore it from memory" do
    key = api.serialize_for_async('books.create', {title:'New Book'})
    expect(key).to be_present
  end

  it "should deserialize a command call" do
    key = api.serialize_for_async('books.create', {title:'New Book'})
    hash = Smooth.config.memory_store.read(key).symbolize_keys
    api_name, object_path, payload = hash.values_at(:api, :object_path, :payload)

    expect(api_name).to eq('My Application')
    expect(Smooth(api_name)).to eq(api)
    expect(Smooth(api_name).lookup(object_path)).to be_present
    expect(payload[:title]).to eq('New Book')
  end
end
