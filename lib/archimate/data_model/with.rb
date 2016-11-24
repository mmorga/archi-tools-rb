# frozen_string_literal: true
module Archimate
  module DataModel
    module With
      def with(options = {})
        self.class.new(to_h.merge(options))
      end

      def parent
        @parent if defined?(@parent)
      end

      def in_model
        @in_model if defined?(@in_model)
      end

      def assign_model(model)
        walk_struct(
          inst_proc: lambda do |n|
            n.instance_variable_set(:@in_model, model)
            model.register(n)
          end
        )
      end

      def struct_instance_variables
        self.class.schema.keys
      end

      def struct_instance_variable_values
        struct_instance_variables.map { |a| send(a.to_sym) }
      end

      def struct_instance_variable_hash
        struct_instance_variables.each_with_object({}) { |i, a| a[i] = send(i.to_sym) }
      end

      def compact
        walk_struct(array_proc: ->(n) { n.compact! })
        self
      end

      # Recursively walk this model and all of it's children calling the passed
      # proc for each instance
      def walk_struct(inst_proc: -> (_n) {}, array_proc: -> (_n) {})
        inst_proc.call(self)
        struct_instance_variable_values.each do |val|
          case val
          when Dry::Struct
            val.walk_struct(inst_proc: inst_proc, array_proc: array_proc)
          when Array
            array_proc.call(val)
            val.each { |i| i.walk_struct(inst_proc: inst_proc, array_proc: array_proc) if i.is_a?(Dry::Struct) }
          end
        end
      end

      def assign_parent(p)
        @parent = p
        struct_instance_variable_values.each do |val|
          case val
          when Dry::Struct
            val.assign_parent(self)
          when Array
            val.each { |i| i.assign_parent(self) if i.is_a?(Dry::Struct) }
          end
        end
      end

      def ancestors
        result = [self]
        p = self
        result << p until (p = p.parent).nil?
        result
      end
    end
  end
end
