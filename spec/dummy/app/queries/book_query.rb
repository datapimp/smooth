class BookQuery < Smooth::Query
  def self.developer_defined_method
    true
  end
end

resource "Books" do
  query do
    def inline_dsl_method
      true
    end
  end
end
