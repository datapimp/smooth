module Smooth
  module Util
    extend self

    def uri_template url_pattern
      URITemplate.new(:colon, url_pattern)
    end

    def extract_url_vars(uri_template, actual_url)
      uri_template.extract(actual_url).tap do |obj|
        obj.symbolize_keys!
      end
    end
  end
end
