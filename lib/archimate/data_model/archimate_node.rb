# frozen_string_literal: true
module Archimate
  module DataModel
    # TODO: This should be obsolete at this point
    class ArchimateNode < Dry::Struct
      using DiffablePrimitive
      using DiffableArray

      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attr_writer :parent_attribute_name
      attr_reader :struct_instance_variables

      def initialize(attributes)
        super
        @struct_instance_variables = self.class.schema.keys
      end

      # TODO: Schedule this for eliminations
      # Outside of test code, this is only used for the Bounds class
      def with(options = {})
        self.class.new(
          struct_instance_variables
            .each_with_object({}) { |i, a| a[i] = self[i] }
            .merge(options)
            .each_with_object({}) { |(k, v), a| a[k] = v.dup }
        )
      end

      # Note: my clone method does one non-idiomatic thing - it does not clone the
      # frozen state. TODO: respect the frozen state of the clone'd object.
      # @deprecated
      def clone
        self.class.new(
          struct_instance_variables
            .each_with_object({}) do |i, a|
              a[i] = self[i].primitive? ? self[i] : self[i].clone
            end
        )
      end

      # Makes a copy of the archimate node which is not frozen
      # @deprecated
      def dup
        self.class.new(
          struct_instance_variables
            .each_with_object({}) do |i, a|
              a[i] = self[i].primitive? ? self[i] : self[i].dup
            end
        )
      end

      # @deprecated
      # def in_model
      #   @in_model if defined?(@in_model)
      # end

      # @deprecated
      def parent
        @parent if defined?(@parent)
      end

      # TODO: this is used only such that every item has an id for sticking in the index.
      # Is this really needed still?
      # @deprecated
      def id
        object_id
      end

      # @deprecated
      def primitive?
        false
      end

      # @deprecated
      def parent=(par)
        return if @parent == parent
        @parent = par
        struct_instance_variables.each do |attrname|
          self[attrname].parent = self
        end
      end

      # @deprecated
      def parent_attribute_name
        return @parent_attribute_name if defined?(@parent_attribute_name)
        parent.find_index(self) if parent&.is_a?(Array)
      end

      # @deprecated
      # def in_model=(model)
      #   return if @in_model == model
      #   @in_model = model unless is_a?(Model)
      #   return
      #   struct_instance_variables.each { |attrname|
      #     puts "#{attrname} is frozen in #{self.class}" if self[attrname].frozen? && self[attrname].is_a?(Array)
      #     self[attrname].in_model = model }
      # end

      # @deprecated
      def build_index(hash_index = {})
        hash_index[id] = self unless id.nil?
        struct_instance_variables.reduce(hash_index) do |a, e|
          self[e].parent_attribute_name = e
          self[e].build_index(a)
        end
      end

      # @deprecated
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

      # @deprecated
      def path(options = {})
        [
          parent&.path(options),
          path_identifier
        ].compact.map(&:to_s).reject(&:empty?).join("/")
      end

      # @deprecated
      def compact!
        struct_instance_variables.each { |attrname| self[attrname].compact! }
        self
      end

      # @deprecated
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

      # @deprecated
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

      # @deprecated
      def referenced_identified_nodes
        struct_instance_variables.reduce([]) do |a, e|
          a.concat(self[e].referenced_identified_nodes)
        end
      end

      private

      # @deprecated
      def path_identifier
        case parent
        when Array
          find_my_index
        else
          parent_attribute_name
        end
      end

      # @deprecated
      def find_my_index
        parent.find_index(self)
      end
    end
  end
end
