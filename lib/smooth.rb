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
