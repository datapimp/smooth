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

  def self.input_argument_names
    required_inputs.keys + optional_inputs.keys
  end

  # Commands are aware of who is running them
  attr_accessor :current_user

  class_attribute :resource_name,
                  :command_action,
                  :event_namespace,
                  :model_class,
                  :base_scope

  def self.base_scope
    @base_scope || :all
  end

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
      value = model_class.to_s
    end

    value
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

    parent_klass = Class.new(base)

    begin
      Object.const_set(klass, parent_klass).tap(&apply_options)
    rescue => ex
      puts ex.message
      puts "Error setting #{ klass } #{ base }. klass is a #{ klass.class }"
    end

    parent_klass
  end

  # Interface Documentation
  #
    def interface_for filter
      self.class.interface_description.filters.send(filter)
    end

    def self.interface_description
      interface_documentation
    end

    def self.interface_documentation
      optional_inputs = input_filters.optional_inputs
      required_inputs = input_filters.required_inputs

      data = {
        required: required_inputs.keys,
        optional: optional_inputs.keys,
        filters: {}
      }

      blk = lambda do |memo, parts, required|
        key, filter = parts

        type        = filter.class.name[/^Mutations::([a-zA-Z]*)Filter$/, 1].underscore
        options     = filter.options.merge(required: required)

        memo[key] = {
          type: type,
          options: options.reject {|k,v| v.nil? },
          description: input_descriptions[key]
        }

        memo
      end

      required_inputs.reduce(data[:filters]) do |memo, parts|
        blk.call(memo, parts, true)
      end

      optional_inputs.reduce(data[:filters]) do |memo, parts|
        blk.call(memo, parts, false)
      end

      data.to_mash
    end

    def self.filter_for_param(param)
      optional_inputs[param] || required_inputs[param]
    end

    def self.filter_options_for_param(param)
      filter_for_param(param).try(:options)
    end

    def self.handle_request(request_object)
      as(request_object.user).run(request_object.params)
    end

end
