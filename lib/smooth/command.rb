require 'smooth/ext/mutations'

class Smooth::Command < Mutations::Command
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

    Object.const_set(klass, Class.new(base))
  end

  def self.filter_explanations
    input_filters.filter_explanations
  end

  def self.scope setting
    @@scope = setting
  end

  def self.params *args, &block
    send(:required, *args, &block)
  end
end
