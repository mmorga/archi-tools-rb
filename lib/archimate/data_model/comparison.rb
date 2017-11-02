# frozen_string_literal: true

module Archimate
  module DataModel
    module Comparison
      def initialize(opts = {})
        self.class.attr_info.each do |sym, attr_info|
          raise "#{self.class} required value for #{sym} is missing." unless attr_info.default != :value_required || opts.include?(sym)
          val = opts.fetch(sym, attr_info.default)
          instance_variable_set("@#{sym}".to_sym, val)
          val.add_reference(self) if val.is_a?(Referenceable)
        end
      end

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

      def inspect
        "#<#{self.class}:#{respond_to?(:id) ? id : object_id}\n    " +
          self.class.attr_info
              .map { |sym, info| info.attr_inspect(self, sym) }
              .compact
              .join("\n    ")
      end

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        AttributeInfo = Struct.new(:comparison_attr, :writable, :default) do
          def attr_inspect(obj, sym)
            case comparison_attr
            when :no_compare
              nil
            when nil
              "#{sym}: #{obj.send(sym)&.inspect}"
            else
              "#{sym}: #{obj.send(sym)&.send(comparison_attr)&.inspect}"
            end
          end
        end

        # Define the reader method (or call model_attr)
        # Append the attr_sym to the @@attrs for the class
        def model_attr(attr_sym, comparison_attr: nil, writable: false, default: :value_required)
          send(:attr_reader, attr_sym)
          attrs = attr_names << attr_sym
          class_variable_set(:@@attr_names, attrs.uniq)
          class_variable_set(
            :@@attr_info,
            attr_info.merge(attr_sym => AttributeInfo.new(comparison_attr, writable, default))
          )
          if comparison_attr != :no_compare
            attrs = comparison_attr_paths << (comparison_attr ? [attr_sym, comparison_attr] : attr_sym)
            class_variable_set(:@@comparison_attr_paths, attrs.uniq)
          end
          return unless writable
          define_method("#{attr_sym}=".to_sym) do |val|
            instance_variable_set(:@hash_key, nil)
            old_val = instance_variable_get("@#{attr_sym}")
            old_val.remove_reference(self) if old_val.is_a?(Referenceable)
            instance_variable_set("@#{attr_sym}".to_sym, val)
            val.add_reference(self) if val.is_a?(Referenceable)
          end
        end

        def attr_names
          class_variable_defined?(:@@attr_names) ? class_variable_get(:@@attr_names) : []
        end

        def attr_info
          class_variable_defined?(:@@attr_info) ? class_variable_get(:@@attr_info) : {}
        end

        def comparison_attr_paths
          class_variable_defined?(:@@comparison_attr_paths) ? class_variable_get(:@@comparison_attr_paths) : []
        end
      end
    end
  end
end
