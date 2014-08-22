module Smooth
  module Documentation

    def self.included base
      base.class_eval do
        attr_accessor :_inline_description

        class << self
          attr_accessor :_inline_description
        end
      end

      base.extend Smooth::Documentation
    end

    def desc description, *args
      self._inline_description = {
        description: description,
        args: args
      }
    end

    def inline_description
      val = self._inline_description && self._inline_description.dup
      self._inline_description = nil
      val
    end
  end
end
