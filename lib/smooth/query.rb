module Smooth
  class Query < Smooth::Command
    include Smooth::Documentation

    # To customize the filtering behavior of the query
    # you can supply your own execute method body. The
    # execute method is expected to mutate the value of the
    # `self.scope` or @scope instance variable and to return
    # something which can be serialized as JSON using the
    # Smooth::Serializer
    def execute
      apply_filters
      scope
    end

    def apply_filters
      params.each(&method(:apply_filter))

      if raw_inputs['ids']
        ids = raw_inputs['ids']
        ids = ids.split(',') if ids.is_a?(String)

        self.scope = self.scope.where(id: Array(ids) )
      end
    end

    def validate
      true
    end

    protected

    def operator_for filter
      specific = interface_for(filter).options.operator
      return specific if specific
      :eq
    end

    def operator_and_type_for filter
      [operator_for(filter),interface_for(filter).type]
    end

    def column_for key
      interface_for(key).options.column || key
    end

    def apply_filter *parts
      key, value = parts.flatten

      operator = operator_for(key)

      value = "%#{value}%" if operator == :like
      value = "#{value}%" if operator == :ends_with
      value = "%#{value}" if operator == :begins_with

      operator = :matches if operator == :like

      column = column_for(key)
      condition = arel_table[column].send(operator, value)

      self.scope = self.scope.merge(self.scope.where(condition))
    end

    def arel_table
      model_class.arel_table
    end

    class_attribute :query_config,
                    :parent_resource

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

      klass = "#{ resource.model_class }#{ name }".singularize + "Query"

      klass = klass.gsub(/\s+/,'')

      apply_options = lambda do |k|
        k.model_class     ||= resource.model_class if resource.model_class

        k.resource_name   = resource.name.to_s if k.resource_name.empty?
        k.command_action  = "query" if k.command_action.empty?
        k.belongs_to_resource(resource)
      end

      if query_klass = Object.const_get(klass) rescue nil
        return query_klass.tap(&apply_options)
      end

      begin
        Object.const_set(klass, Class.new(base)).tap(&apply_options)
      rescue
        binding.pry
      end
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

    def self.respond_to_find_request request_object, options={}
      outcome = as(request_object.user).run(request_object.params)


      Smooth::Response.new(nil).tap do |response|
        response.command_action = :find
        response.event_namespace = event_namespace
        response.request_headers = request_object.headers

        if outcome.success?
          response.object = outcome.result.find(request_object.params[:id])
          response.success = true
          response.serializer = find_serializer_for(request_object)
        end
      end
    end

    def self.response_class
      Smooth::Query::Response
    end

    class Response < Smooth::Response
      def serializer
        if command_action.to_sym == :find
          @serializer
        else
          Smooth::ArraySerializer
        end
      end

      def options
        @serializer_options.tap do |o|
          o[:each_serializer] = @serializer unless command_action == :find
          o[:scope] = current_user
        end
      end

      def object
        return @object if @object

        if command_action.to_sym == :find
          outcome.result
        elsif success? && command_action.to_sym == :query
          outcome.result.to_a
        end
      end
    end

  end
end
