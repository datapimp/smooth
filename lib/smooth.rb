$:.unshift File.dirname(__FILE__)

load_rails_dependencies = lambda do
  require 'active_support/core_ext'
  require 'active_support/notifications'
  require 'active_record'
end

load_dependencies = lambda do
  require 'active_model_serializers'
  require 'hashie'
  require 'mutations'
  require 'logger'
  require 'sinatra'
  require 'singleton'
  require 'yaml'
end

begin
  load_dependencies.call()

  unless defined?(::Rails)
    load_rails_dependencies.call()
  end
rescue LoadError
  require 'rubygems'
  retry
end


require "smooth/ext/core"
require "smooth/documentation"
require "smooth/event"

require "smooth/api"
require 'smooth/api/policy'
require 'smooth/api/tracking'

require "smooth/cache"

require 'smooth/ext/mutations'
require 'smooth/command/instrumented'
require "smooth/command"

require "smooth/example"
require "smooth/response"

require "smooth/query"
require "smooth/resource"
require "smooth/serializer"

require "smooth/dsl_adapter"
require "smooth/active_record/adapter"
require "smooth/model_adapter"
require "smooth/user_adapter"

require "smooth/configuration"
require "smooth/version"

module Smooth
  extend Smooth::Api::Tracking
  extend Smooth::Resource::Tracking
  extend Smooth::Event::Adapter
  extend Smooth::DslAdapter

  def self.command
    config.command_class
  end

  def self.query
    config.query_class
  end

  def self.serializer
    config.serializer_class
  end

  def self.config &block
    block_given = block_given?
    Smooth::Configuration.instance.tap do |cfg|
      cfg.instance_eval(&block) if block_given
    end
  end

  def self.events
    Smooth::Event::Proxy
  end

  def self.eager_load_from_app_folders
    return unless config.eager_load_app_folders

    config.app_folder_paths.each do |folder|
      next unless folder.exist?

      folder.children.select {|p| p.extname == '.rb' }.each {|f| require(f) }
    end
  end

  def self.app
    @application || raise("Application not initialized")
  end

  def self.application options={}, &block
    @application ||= Smooth::Application.new(options, &block)
  end

  def self.root
    Smooth.config.root
  end

  def self.models_path
    config.models_path
  end

  def self.active_record
    Smooth::AR::Adapter
  end

  def self.env
    ENV['SMOOTH_ENV'] || ENV['RACK_ENV'] || ENV['RAILS_ENV'] || "development"
  end

  if defined?(::Rails)
    def self.root
      ::Rails.root
    end

    class Engine < ::Rails::Engine
      initializer 'smooth.load_resources' do |app|
        %w{app/apis app/resources}.each do |check|
          if (folder = app.root.join(check)).exist?
            folder.children.select {|f| f.extname == '.rb'}.each do |f|
              require(f)
            end
          end
        end

        #Smooth.eager_load_from_app_folders()
      end
    end
  end


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
