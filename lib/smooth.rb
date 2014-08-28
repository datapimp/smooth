$:.unshift File.dirname(__FILE__)

load_dependencies = lambda do
  require 'hashie'
  require 'active_support/core_ext'
  require 'active_support/notifications'
  require 'active_model_serializers'
  require 'mutations'
end

begin
  load_dependencies.call()
rescue LoadError
  require 'rubygems'
  retry
end


require "smooth/ext/core"
require "smooth/documentation"
require "smooth/event"

require "smooth/api"
require "smooth/cache"
require "smooth/command"
require "smooth/example"
require "smooth/query"
require "smooth/resource"
require "smooth/serializer"

require "smooth/user_adapter"

require "smooth/configuration"
require "smooth/version"

module Smooth
  extend Smooth::Api::Tracking
  extend Smooth::Resource::Tracking
  extend Smooth::Event::Adapter
  extend Smooth::Dsl

  def self.command
    config.command_class
  end

  def self.query
    config.query_class
  end

  def self.serializer
    config.serializer_class
  end

  def self.config
    Smooth::Configuration.instance
  end

  def self.events
    Smooth::Event::Proxy
  end

  class Engine < ::Rails::Engine
    initializer 'smooth.load_resources', :before => :build_middleware_stack do |app|
      app_root = app.config.root.join("app")

      %w{smooth apis resources}.each do |check_folder|
        app_root.join(check_folder).children.each {|f| require(f) } if app_root.join(check_folder).exist?
      end
    end

  end if defined?(::Rails)

  require 'smooth/model_adapter'
  ActiveRecord::Base.send(:include, Smooth::ModelAdapter) if defined?(ActiveRecord::Base)
end

class Object
  # Provides a global helper for looking up things in the Smooth object system.
  #
  # Example:
  #
  #   Smooth() #=> returns the current api
  #   Smooth('books') #=> returns the books resource
  #   Smooth('books.create') #=> returns the create command, for the books resource
  #
  def Smooth api_or_resource_name=nil
    return Smooth.current_api if api_or_resource_name.nil?

    if api_or_resource_name.to_s.include?(Smooth.config.object_path_separator)
      return Smooth.current_api.lookup_object_by(api_or_resource_name)
    end

    Smooth.fetch_api(api_or_resource_name) || Smooth.current_api.resource(api_or_resource_name)
  end
end
