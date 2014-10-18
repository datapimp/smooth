require 'singleton'

module Smooth
  def self.cache
    Smooth::Cache.instance
  end

  class Cache
    include Singleton

    def method_missing(meth, *args, &block)
      if defined? ::Rails
        return ::Rails.cache.send(meth, *args, &block)
      end

      super
    end
  end
end
