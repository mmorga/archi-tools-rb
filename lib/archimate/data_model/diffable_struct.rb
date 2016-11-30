# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffableStruct
      using DiffablePrimitive
      using DiffableArray

      def primitive?
        false
      end

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
        return [Diff::Delete.new(self)] if other.nil?
        raise TypeError, "Expected other <#{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
        struct_instance_variables.each_with_object([]) do |k, a|
          val = send(k)
          if val.nil?
            a.concat([DataModel::Insert.new(other, k)]) unless other.send(k).nil?
          elsif val.primitive?
            a.concat(val.diff(other.send(k), self, other, k))
          else
            a.concat(val.diff(other.send(k)))
          end
        end
      end

      def match(other)
        is_a?(other.class) &&
          ((respond_to?(:id) && id == other.id) || self == other)
      end

      def struct_instance_variables
        self.class.schema.keys
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

      def path
        [
          parent&.path,
          parent&.attribute_name(self)
        ].compact.reject(&:empty?).join("/")
      end

      def attribute_name(v)
        self.class.schema.keys.reduce do |a, e|
          a = e if v.equal?(send(e))
          a
        end
      end

      def apply_diff(diff)
        diff.apply(lookup_in_this_model(diff.effective_element))
      end

      def lookup_in_this_model(remote_element)
        if remote_element.respond_to?(:id)
          lookup(remote_element.id)
        elsif remote_element.is_a?(Array)
          send(remote_element.parent.attribute_name(remote_element))
        else
          raise TypeError, "Don't know how to look up #{remote_element.class} in #{self.class}"
        end
      end

      def delete(attrname, _value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{self.class.schema.keys.map(&:to_s).join(',')}"
        ) if attrname.nil? || attrname.empty?
        instance_variable_set("@#{attrname}".to_sym, nil)
        self
      end

      def insert(attrname, value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{self.class.schema.keys.map(&:to_s).join(',')}"
        ) if attrname.nil? || attrname.empty?
        instance_variable_set("@#{attrname}".to_sym, value)
      end

      def change(attrname, value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{self.class.schema.keys.map(&:to_s).join(',')}"
        ) if attrname.nil? || attrname.empty?
        instance_variable_set("@#{attrname}".to_sym, value)
      end
    end
  end
end
