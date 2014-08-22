require 'singleton'

module Smooth
  class Configuration
    include Singleton

    cattr_accessor :query_class,
                   :command_class,
                   :serializer_class

    @@query_class       = Smooth::Query
    @@command_class     = Smooth::Command
    @@serializer_class  = defined?(ApplicationSerializer) ? ApplicationSerializer : Smooth::Serializer

    def self.method_missing meth, *args, &block
      instance.send(meth, *args, &block)
    end
  end
end
