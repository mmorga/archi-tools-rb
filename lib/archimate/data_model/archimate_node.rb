# frozen_string_literal: true
module Archimate
  module DataModel
    class ArchimateNode < Dry::Struct
      using DiffablePrimitive
      using DiffableArray

      constructor_type :schema

      def with(options = {})
        self.class.new(
          struct_instance_variables
            .each_with_object({}) { |i, a| a[i] = self[i] }
            .merge(options)
            .each_with_object({}) { |(k, v), a| a[k] = v.dup }
        )
      end

      # Note: my clone method does one non-idiomatic thing - it does not clone the
      # frozen state. TODO: respeect the frozen state of the clone'd object.
      def clone
        self.class.new(
          struct_instance_variables
            .each_with_object({}) do |i, a|
              a[i] = self[i].primitive? ? self[i] : self[i].clone
            end
        )
      end

      # Makes a copy of the archimate node which is not frozen
      def dup
        self.class.new(
          struct_instance_variables
            .each_with_object({}) do |i, a|
              a[i] = self[i].primitive? ? self[i] : self[i].dup
            end
        )
      end

      def primitive?
        false
      end

      def assign_parent(par)
        @parent = par
        struct_instance_variables.each do |attrname|
          self[attrname].assign_parent(self)
        end
      end

      def parent
        @parent if defined?(@parent)
      end

      def assign_model(model)
        @in_model = model unless is_a?(Model)
        struct_instance_variables.each do |attrname|
          self[attrname].assign_model(model)
        end
      end

      def in_model
        @in_model if defined?(@in_model)
      end

      def build_index(hash_index = {})
        hash_index[id] = self
        struct_instance_variables.reduce(hash_index) { |a, e| self[e].build_index(a) }
      end

      def diff(other)
        raise ArgumentError, "other expected to be not nil" if other.nil?
        raise TypeError, "Expected other <#{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
        struct_instance_variables.each_with_object([]) do |k, a|
          val = self[k]
          if val.nil?
            a.concat([Diff::Insert.new(Diff::ArchimateNodeAttributeReference.new(other, k))]) unless other[k].nil?
          elsif val.primitive?
            a.concat(val.diff(other[k], self, other, k))
          else
            a.concat(val.diff(other[k]))
          end
        end
      end

      def patch(a_diff)
        case a_diff
        when Diff::Delete
          # TODO: maybe an issue here is that my diffs are poorly formed
          # diff should be of the form: something that responds to parent and an attribute name or index or "after"
          parent.delete(parent.attribute_name(self), self)
        when Diff::Insert, Diff::Change

        when Diff::Move
          raise ArgumentError, "Move is an invalid patch to apply to #{self.class}"
        end
      end

      def match(other)
        self == other
      end

      def ancestors
        result = [self]
        p = self
        result << p until (p = p.parent).nil?
        result
      end

      def path(options = {})
        [
          parent&.path(options),
          parent&.attribute_name(self, options)
        ].compact.map(&:to_s).reject(&:empty?).join("/")
      end

      def struct_instance_variables
        self.class.schema.keys
      end

      def compact!
        struct_instance_variables.each { |attrname| self[attrname].compact! }
        self
      end

      def attribute_name(v, _options = {})
        struct_instance_variables.reduce do |a, e|
          a = e if v.equal?(self[e])
          a
        end
      end

      def delete(attrname, value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{struct_instance_variables.map(&:to_s).join(',')}"
        ) if attrname.nil? || attrname.empty?
        in_model&.deregister(value)
        instance_variable_set("@#{attrname}".to_sym, nil)
        self
      end

      def insert(attrname, value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{struct_instance_variables.map(&:to_s).join(',')}"
        ) if attrname.nil? #  || attrname.empty?
        # value = value.clone
        in_model&.register(value, self)

        instance_variable_set("@#{attrname}".to_sym, value)
        self
      end

      def change(attrname, from_value, to_value)
        raise(
          ArgumentError,
          "attrname was blank must be one of: #{struct_instance_variables.map(&:to_s).join(',')}"
        ) if attrname.nil? || attrname.empty?
        # value = to_value.clone
        in_model&.deregister(from_value)
        in_model&.register(to_value, self)

        instance_variable_set("@#{attrname}".to_sym, to_value)
        self
      end

      def referenced_identified_nodes
        struct_instance_variables.reduce([]) do |a, e|
          a.concat(self[e].referenced_identified_nodes)
        end
      end

      def identified_nodes(starting_ary = [])
        struct_instance_variables.reduce(starting_ary) do |a, e|
          a.concat(self[e].identified_nodes)
        end
      end
    end
  end
end
