module Smooth
  class Resource
    module Templating

      FakerGroups = %w{
        Address Lorem Color Company Food HipterIpsum Internet Job Name Movie PhoneNumber Product Unit Vehicle Venue Skill
      }

      def self.fakers
        FakerGroups.flat_map do |group|
          prefix = group.to_s.underscore.downcase
          space = Faker.const_get(group.to_sym) rescue nil

          if space && space.class == Module
            (space.methods - Object.methods - [:k, :underscore]).map {|m| "#{prefix}.#{m}"}
          end
        end.compact.uniq
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
