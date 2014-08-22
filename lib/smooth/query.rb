module Smooth
  class Query
    include Smooth::Documentation

    class_attribute :query_config
    self.query_config = Hashie::Mash.new(base:{})

    def self.configure options, resource=nil
      resource ||= Smooth.current_resource
      klass = define_or_open(options, resource)

      Array(options.blocks).each do |blk|
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

      if query_klass = Object.const_get(klass) rescue nil
        return query_klass
      end

      Object.const_set(klass, Class.new(base))
    end

    def self.start_from *args, &block
      options = args.extract_options!
      config.start_from = options
    end

    def self.params *args, &block
      options = args.extract_options!
      config.params = options
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
