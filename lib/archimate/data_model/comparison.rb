# frozen_string_literal: true

module Archimate
  module DataModel
    module Comparison
      def hash
        @hash_key ||=
          self.class.attr_names.reduce(self.class.hash) { |ha, attr| ha ^ send(attr).hash }
      end

      def ==(other)
        return true if equal?(other)
        other.is_a?(self.class) &&
          self.class.comparison_attr_paths.all? do |attr|
            dig(*attr) == other.dig(*attr)
          end
      end

      def [](sym)
        send(sym)
      end

      def dig(*args)
        return self if args.empty?
        val = send(args.shift)
        return val if args.empty?
        val&.dig(*args)
      end

      def to_h
        self.class.attr_names.each_with_object({}) { |i, a| a[i] = send(i) }
      end

      def each(&blk)
        self.class.comparison_attr_paths.each(&blk)
      end

      def pretty_print(pp)
        pp.object_address_group(self) do
          pp.seplist(self.class.comparison_attr_paths, proc { pp.text ',' }) do |attr|
            column_value = dig(*attr)
            pp.breakable ' '
            pp.group(1) do
              pp.text Array(attr).map(&:to_s).join(".")
              pp.text ':'
              pp.breakable
              pp.pp column_value
            end
          end
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Define the reader method (or call model_attr)
        # Append the attr_sym to the @@attrs for the class
        def model_attr(attr_sym, comparison_attr: nil, writable: false)
          send(:attr_reader, attr_sym)
          attrs = attr_names << attr_sym
          class_variable_set(:@@attr_names, attrs.uniq)

          if comparison_attr != :no_compare
            attrs = comparison_attr_paths << (comparison_attr ? [attr_sym, comparison_attr] : attr_sym)
            class_variable_set(:@@comparison_attr_paths, attrs.uniq)
          end
          if writable
            define_method("#{attr_sym}=".to_sym) do |val|
              instance_variable_set(:@hash_key, nil)
              instance_variable_set("@#{attr_sym}".to_sym, val)
            end
          end
        end

        def attr_names
          class_variable_defined?(:@@attr_names) ? class_variable_get(:@@attr_names) : []
        end

        def comparison_attr_paths
          class_variable_defined?(:@@comparison_attr_paths) ? class_variable_get(:@@comparison_attr_paths) : []
        end
      end
    end
  end
end
