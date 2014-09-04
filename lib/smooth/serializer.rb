module Smooth
  class Serializer < ActiveModel::Serializer
    include Smooth::Documentation

    class_attribute :attribute_descriptions,
                    :relationship_descriptions

    self.attribute_descriptions   = {}.to_mash
    self.relationship_descriptions = {}.to_mash

    def self.method_added method_name
      if documented = inline_description
        attribute_descriptions[method_name.to_sym] = documented
      end
    end

    def self.schema_attributes
      schema[:attributes]
    end

    def self.schema_associations
      schema[:associations]
    end

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
      base          = Smooth.serializer

      name = options.name
      name = nil if name == "Default"

      klass = "#{ resource_name }#{ name }".singularize + "Serializer"

      if serializer_klass = Object.const_get(klass) rescue nil
        return serializer_klass
      end

      parent_klass = Class.new(base)

      begin
        Object.const_set(klass, parent_klass)
      rescue => ex
        puts ex.message
        puts "Error setting #{ klass } #{ base }. klass is a #{ klass.class }"
      end

      parent_klass
    end

    def self.documentation_for_attribute attribute
      attribute_descriptions[attribute.to_sym]
    end

    def self.documentation_for_association association
      relationship_descriptions[association.to_sym]
    end

    def self.documentation
      attribute_descriptions.merge(relationship_descriptions).to_mash
    end

    def self.interface_documentation
      documentation
    end

    def self.attribute attr, options={}
      documented = inline_description

      if documented
        attribute_descriptions[attr.to_sym] = documented
      end

      super
    end

    def self.has_one attr, options={}
      documented = inline_description

      if documented
        relationship_descriptions[attr.to_sym] = documented
      end

      super
    end

    def self.has_many attr, options={}
      documented = inline_description

      if documented
        relationship_descriptions[attr.to_sym] = documented
      end

      super
    end

    def self.serialize_object(object, options={})
      new(object).as_json(options)
    end
  end
end
