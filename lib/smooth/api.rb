require 'smooth/dsl'

module Smooth
  class Api
    include Smooth::Documentation

    def self.default
      @default ||= Smooth::Api.new(:default)
    end

    attr_accessor :name,
                  :_version_config,
                  :_resources,
                  :_policies

    def initialize(name, options={})
      @name       = name.to_s
      @options    = options

      @_resources   = {}
      @_policies    = {}
    end

    def version config=nil
      @_version_config = config if config
      @_version_config
    end

    def policy policy_name, options={}, &block
      if obj = _policies[policy_name.to_sym]
        obj.apply_options(options) unless options.empty?
        obj.instance_eval(&block) if block_given?
        obj

      elsif options.empty? && !block_given?
        nil

      elsif block_given?
        obj = Smooth::Api::Policy.new(policy_name, options, &block)
        _resources[policy_name.to_sym] = obj
      end
    end

    def has_resource? resource_name
      resources.has_key?(resource_name.to_sym)
    end

    def resource resource_name, options={}, &block
      api_name = self.name

      if existing = _resources[resource_name.to_sym]
        existing.apply_options(options) unless options.empty?
        existing.instance_eval(&block) if block_given?
        existing

      elsif options.empty? && !block_given?
        existing = nil

      elsif block_given?
        created = Smooth::Resource.new(resource_name, options, &block).tap do |obj|
          obj.api_name = api_name
        end

        _resources[resource_name.to_sym] = created
      end
    end

  end
end

require 'smooth/api/tracking'
require 'smooth/api/policy'
