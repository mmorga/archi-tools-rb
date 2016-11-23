# frozen_string_literal: true
module Archimate
  module DataModel
    module With
      def with(options = {})
        self.class.new(to_h.merge(options))
      end

      def parent
        in_model&.lookup(parent_id)
      end

      def in_model
        instance_variable_get(:@in_model) if defined?(@in_model)
      end

      def assign_model(model)
        instance_variable_set(:@in_model, model)
        struct_instance_variable_values.each do |val|
          case val
          when Dry::Struct
            val.assign_model(model)
          when Array
            val.each { |i| i.assign_model(model) if i.is_a?(Dry::Struct) }
          end
        end
      end

      def struct_instance_variables
        self.class.schema.keys
      end

      def struct_instance_variable_values
        struct_instance_variables.map { |a| instance_variable_get("@#{a}") }
      end

      def struct_instance_variable_hash
        struct_instance_variables.each_with_object({}) { |i, a| a[i] = instance_variable_get("@#{i}") }
      end

      def compact
        struct_instance_variable_values.each do |val|
          case val
          when Dry::Struct
            val.compact
          when Array
            val.compact!
            val.each { |i| i.compact if i.is_a?(Dry::Struct) }
          end
        end
        self
      end
    end
  end
end
