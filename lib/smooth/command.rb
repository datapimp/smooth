require 'smooth/ext/mutations'
require 'smooth/command/instrumented'

class Smooth::Command < Mutations::Command
  include Instrumented

  class_attribute :resource_name,
                  :command_action,
                  :event_namespace

  def self.filter_explanations
    input_filters.filter_explanations
  end

  def self.scope setting
    @@scope = setting
  end

  def self.params *args, &block
    send(:required, *args, &block)
  end

  def event_namespace; self.class.event_namespace; end

  def self.event_namespace
    @event_namespace || "#{ command_action }.#{ resource_name.singularize.underscore }".downcase
  end

  # DSL Hooks
  #
  #
  def self.configure options, resource=nil
    resource ||= Smooth.current_resource
    klass = define_or_open(options, resource)

    Array(options.blocks).each do |blk|
      klass.class_eval(&blk)
    end

    klass
  end

  def self.define_or_open(options, resource)
    resource_name = resource.name.to_s.singularize
    base          = Smooth.command

    name = options.name.to_s.camelize
    klass = "#{ name }#{ resource_name }"

    if command_klass = Object.const_get(klass) rescue nil
      return command_klass
    end

    Object.const_set(klass, Class.new(base)).tap do |k|
      k.resource_name = resource.name.to_s
      k.command_action  = options.name.to_s
    end
  end
end
