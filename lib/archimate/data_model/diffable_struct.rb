# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffableStruct
      using DiffablePrimitive
      using DiffableArray

      def assign_parent(p)
        @parent = p
        to_h.keys.each do |k|
          send(k).assign_parent(self)
        end
      end

      def parent
        @parent if defined?(@parent)
      end

      def assign_model(model)
        walk_struct(
          inst_proc: lambda do |n|
            n.instance_variable_set(:@in_model, model)
            model.register(n)
          end
        )
      end

      def in_model
        @in_model if defined?(@in_model)
      end

      def diff(other)
        raise TypeError, "Expected other <#{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
        to_h.keys.reduce([]) do |a, k|
          a.concat(send(k).diff(other.send(k)))
        end
      end

      def match(other)
        is_a?(other.class) &&
          ((respond_to?(:id) && id == other.id) || self == other)
      end

      def struct_instance_variables
        to_h.keys
      end

      def compact
        walk_struct(array_proc: ->(n) { n.compact! })
        self
      end

      # Recursively walk this model and all of it's children calling the passed
      # proc for each instance
      def walk_struct(inst_proc: -> (_n) {}, array_proc: -> (_n) {})
        inst_proc.call(self)
        to_h.keys.map { |k| send(k) }.each do |val|
          case val
          when Dry::Struct
            val.walk_struct(inst_proc: inst_proc, array_proc: array_proc)
          when Array
            array_proc.call(val)
            val.each { |i| i.walk_struct(inst_proc: inst_proc, array_proc: array_proc) if i.is_a?(Dry::Struct) }
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
