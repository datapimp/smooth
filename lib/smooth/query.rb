module Smooth
  class Query < Smooth::Command
    include Smooth::Documentation

    def execute
      respond
      scope
    end

    def validate
      true
    end

    def respond
      params.each(&method(:apply_filter))
    end

    def apply_filter *parts
      key, value = parts.flatten

      operator = operator_for(key)

      value = "%#{value}%" if operator == :like
      operator = :matches if operator == :like

      condition = arel_table[key].send(operator, value)

      self.scope = self.scope.merge(self.scope.where(condition))
    end

    def arel_table
      model_class.arel_table
    end

    class_attribute :query_config
    self.query_config = Hashie::Mash.new(base:{})

    def self.configure dsl_config_object, resource=nil
      resource ||= Smooth.current_resource
      klass = define_or_open(dsl_config_object, resource)

      Array(dsl_config_object.blocks).each do |blk|
        klass.class_eval(&blk)
      end

      klass
    end

    def self.define_or_open(options, resource)
      resource_name = resource.name
      base          = Smooth.query

      name = options.name
      name = nil if name == "Default"

      klass = "#{ resource_name }#{ name }".singularize + "Query"

      apply_options = lambda do |k|
        k.model_class     ||= resource.model_class if resource.model_class

        k.resource_name   = resource.name.to_s if k.resource_name.empty?
        k.command_action  = "query" if k.command_action.empty?
      end

      if query_klass = Object.const_get(klass) rescue nil
        return query_klass.tap(&apply_options)
      end

      Object.const_set(klass, Class.new(base)).tap(&apply_options)
    end

    def self.start_from *args, &block
      options = args.extract_options!
      config.start_from = options
    end

    def params
      inputs
    end

    def self.params *args, &block
      options = args.extract_options!
      config.params = options
      send(:optional, *args, &block)
    end

    def self.role name, &block
      @current_config = name
      instance_eval(&block) if block_given?
    end

    def self.config
      val = query_config.send(@current_config || :base)

      if val.nil?
        val = query_config[@current_config] = {}
        return config
      end

      val
    end

  end
end
