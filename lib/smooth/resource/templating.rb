module Smooth
  class Resource
    module Templating

      def self.included base
        require 'factory_girl' unless defined?(::FactoryGirl)
        require 'faker' unless defined?(::Faker)
      end

      def self.fakers
        (Faker.constants - [:Config,:Base,:VERSION]).flat_map do |group|
          prefix = group.to_s.downcase
          (Faker.const_get(group).methods - Object.methods - Faker::Base.methods).map {|m| "#{prefix}.#{m}" }
        end
      end

      def create_from_template(name=nil, *args, &block)
        if name.is_a?(Hash)
          args.unshift(name)
          name = @template_name
        end
        FactoryGirl.create(name || @template_name, *args, &block)
      end

      def build_from_template(name=nil, *args, &block)
        if name.is_a?(Hash)
          args.unshift(name)
          name = @template_name
        end

        FactoryGirl.build(name || @template_name, *args, &block)
      end

      def template name=nil, *args, &block
        options = args.extract_options!

        if name.nil?
          name = model_class.table_name.singularize.to_sym
          @template_name ||= name
        end

        options[:class] ||= model_class

        FactoryGirl.define do
          factory(name, options, &block)
        end
      end

      # Just allows us to wrap template definitions
      def templates &block
        instance_eval(&block)
      end

    end
  end
end
