require 'smooth/ext/mutations'
require 'smooth/command/instrumented'

class Smooth::Command < Mutations::Command
  include Instrumented

  def self.as current_user
    require 'smooth/command/run_proxy' unless defined?(RunProxy)
    RunProxy.new(current_user, self)
  end

  # DSL Improvements English
  def self.params *args, &block
    send(:required, *args, &block)
  end

  def self.interface *args, &block
    send(:required, *args, &block)
  end

  # Commands are aware of who is running them
  attr_accessor :current_user

  class_attribute :resource_name,
                  :command_action,
                  :event_namespace,
                  :model_class,
                  :base_scope

  # Returns the model scope for this command.  If a scope method
  # is set on this command, it will make sure to scope the model
  # by that method.  It will pass whatever arguments you pass to scope
  # to the scope method.  if you pass no args, and the scope requires one,
  # we will assume the user wants us to pass the current user of the command
  def scope *args
    @scope ||= begin
                meth = model_class.send(:method, self.class.base_scope)

                if meth.arity.abs >= 1
                  args.push(current_user) if args.empty?
                  model_class.send(self.class.base_scope, *args)
                else
                  model_class.send(self.class.base_scope)
                end
               end
  end

  def scope= new_scope
    @scope = new_scope || scope
  end

  def self.scope setting=nil
    self.base_scope= setting if setting
    self.base_scope || :all
  end

  def self.event_namespace
    @event_namespace || "#{ command_action }.#{ resource_alias }".downcase
  end

  def self.resource_alias
    resource_name.singularize.underscore
  end

  def self.resource_name
    value = @resource_name.to_s

    if value.empty? && model_class
      model_class.to_s
    end
  end

  def event_namespace; self.class.event_namespace; end
  def resource_name; self.class.resource_name; end
  def resource_alias; self.class.resource_alias; end
  def model_class; self.class.model_class; end

  # DSL Hooks
  #
  #
  def self.configure dsl_config_object, resource=nil
    resource ||= Smooth.current_resource
    klass = define_or_open(dsl_config_object, resource)

    Array(dsl_config_object.blocks).each do |blk|
      klass.class_eval(&blk)
    end

    klass
  end

  def self.define_or_open(options, resource)
    resource_name = resource.name.to_s.singularize
    base          = Smooth.command

    name = options.name.to_s.camelize
    klass = "#{ name }#{ resource_name }"

    apply_options = lambda do |k|
      k.model_class     ||= resource.model_class if resource.model_class

      k.resource_name   = resource.name.to_s
      k.command_action  = options.name.to_s
    end

    if command_klass = Object.const_get(klass) rescue nil
      return command_klass.tap(&apply_options)
    end

    Object.const_set(klass, Class.new(base)).tap(&apply_options)
  end
end
