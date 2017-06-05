# frozen_string_literal: true
module Archimate
  module DataModel
    class ArchimateNode < Dry::Struct
      using DiffablePrimitive
      using DiffableArray

      constructor_type :schema # specifies constructor style for Dry::Struct

      attr_writer :parent_attribute_name
      attr_reader :struct_instance_variables

      def initialize(attributes)
        super
        @struct_instance_variables = self.class.schema.keys
      end

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

      def in_model
        @in_model if defined?(@in_model)
      end

      def parent
        @parent if defined?(@parent)
      end

      def id
        object_id
      end

      def ancestors
        result = [self]
        p = self
        result << p until (p = p.parent).nil?
        result
      end

      def primitive?
        false
      end

      def parent=(par)
        @parent = par
        struct_instance_variables.each do |attrname|
          self[attrname].parent = self
        end
      end

      def parent_attribute_name
        return @parent_attribute_name if defined?(@parent_attribute_name)
        parent.find_index(self) if parent&.is_a?(Array)
      end

      def in_model=(model)
        @in_model = model unless is_a?(Model)
        struct_instance_variables.each { |attrname| self[attrname].in_model = model }
      end

      def build_index(hash_index = {})
        hash_index[id] = self unless id.nil?
        struct_instance_variables.reduce(hash_index) do |a, e|
          self[e].parent_attribute_name = e
          self[e].build_index(a)
        end
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

      def path(options = {})
        [
          parent&.path(options),
          path_identifier
        ].compact.map(&:to_s).reject(&:empty?).join("/")
      end

      def compact!
        struct_instance_variables.each { |attrname| self[attrname].compact! }
        self
      end

      def delete(attrname)
        if !attrname || attrname.empty?
          raise(
            ArgumentError,
            "attrname was blank must be one of: #{struct_instance_variables.map(&:to_s).join(',')}"
          )
        end
        in_model&.deregister(self[attrname])
        instance_variable_set("@#{attrname}".to_sym, nil)
        self
      end

      def set(attrname, value)
        if !attrname
          raise(
            ArgumentError,
            "attrname was blank must be one of: #{struct_instance_variables.map(&:to_s).join(',')}"
          )
        end #  || attrname.empty?
        # value = value.clone
        in_model&.register(value, self)
        instance_variable_set("@#{attrname}".to_sym, value)
        self
      end

      def referenced_identified_nodes
        struct_instance_variables.reduce([]) do |a, e|
          a.concat(self[e].referenced_identified_nodes)
        end
      end

      def element_by_id(element_id)
        return nil unless element_id
        in_model&.lookup(element_id)
      end

      private

      def path_identifier
        case parent
        when Array
          find_my_index
        else
          parent_attribute_name
        end
      end

      def find_my_index
        parent.find_index(self)
      end
    end
  end
end
