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
            dig(*attr) == other.dig(*attr) # TODO: how to pass array val to var length ruby func
          end
      end

      def dig(*args)
        ary = Array.new(args)
        return self if ary.empty?
        val = send(ary.shift)
        return val if ary.empty?
        val&.dig(*ary)
      end

      def to_h
        self.class.attr_names.each_with_object({}) { |i, a| a[i] = send(i) }
      end

      def each(&blk)
        self.class.comparison_attr_paths.each(&blk)
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
          attrs = comparison_attr_paths << (comparison_attr ? [attr_sym, comparison_attr] : attr_sym)
          class_variable_set(:@@comparison_attr_paths, attrs.uniq)
          if (writable)
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
