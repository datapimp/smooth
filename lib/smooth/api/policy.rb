module Smooth
  class Api
    class Policy
      include Smooth::Documentation

      attr_accessor :name

      def initialize(name, options = {})
        @name = name
        @options = options
      end

      def apply_options(*opts)
        @options.send(:merge!, *opts)
      end
    end
  end
end
