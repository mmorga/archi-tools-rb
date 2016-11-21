# frozen_string_literal: true
module Archimate
  module Diff
    class Context
      attr_reader :base_model, :local_model, :base, :local, :path_stack

      def initialize(base_model, local_model, base, local, path = [])
        @base_model = base_model
        @local_model = local_model
        @base = base
        @local = local
        raise TypeError, "Both models must be the same type" unless base.nil? || local.nil? || base.class == local.class
        @path_stack = Array(path)
        if @path_stack.empty?
          m = @base || @local
          if m.is_a?(DataModel::Model)
            root = m.class.name.split('::').last
            root += "<#{m.id}>" if m.respond_to?(:id)
            @path_stack << root
          end
        end
      end

      # TODO: Refactor this. Can be a lot more clear. Maybe use refinements?
      def diffs
        return [] if base == local
        return [Insert.new(path_str, local_model, local)] if base.nil?
        return [Delete.new(path_str, base_model, base)] if local.nil?

        if base.is_a?(Dry::Struct)
          # TODO: Use an attribute in the object for this so we can only diff
          # against certain attributes rather than all.
          base.comparison_attributes.reject { |i| i == :@schema }.each_with_object([]) do |i, a|
            @path_stack.push i.to_s.delete('@')
            a.concat(
              apply_context(
                Context.new(base_model, local_model, base.instance_variable_get(i), local.instance_variable_get(i)).diffs
              )
            )
            @path_stack.pop
          end
        elsif base.is_a?(Array) # TODO: this probably isn't right yet
          diff_list = []
          base_idx = 0
          local_idx = 0
          while base_idx < base.size || local_idx < local.size
            if base_idx >= base.size
              idx = base.size
              until local_idx >= local.size
                diff_list << Insert.new("[#{local_idx}]", local_model, local[local_idx])
                idx += 1
                local_idx += 1
              end
            elsif local_idx >= local.size
              idx = base.size
              until base_idx >= base.size
                diff_list << Delete.new("[#{base_idx}]", base_model, base[base_idx])
                idx += 1
                base_idx += 1
              end
            elsif base[base_idx] == local[local_idx]
              base_idx += 1
              local_idx += 1
            elsif match(base[base_idx], local[local_idx])
              diff_list << Context.new(base_model, local_model, base[base_idx], local[local_idx], "[#{local_idx}]").diffs
              base_idx += 1
              local_idx += 1
            elsif local[local_idx + 1..-1].any? { |i| match(i, base[base_idx]) }
              diff_list << Insert.new("[#{base_idx}]", local_model, local[local_idx])
              local_idx += 1
            else
              diff_list << Delete.new("[#{base_idx}]", base_model, base[base_idx])
              base_idx += 1
            end
          end
          diff_list.flatten
        elsif base.is_a?(Hash) # TODO: Refactor
          raise "Woah - I didn't expect any more hashes."
        else
          [Change.new(path_str, base_model, local_model, base, local)]
        end
      end

      private

      def match(a, b)
        a.is_a?(b.class) &&
          ((a.respond_to?(:id) && a.id == b.id) || a == b)
      end

      def path_str
        @path_stack.compact.delete_if(&:empty?).join("/")
      end

      def apply_context(diffs)
        diffs.map do |d|
          path = @path_stack.dup
          unless d.path.nil?
            if d.path.is_a?(Integer)
              path << "[#{d.path}]"
            else
              path << d.path.to_s unless d.path.to_s.empty?
            end
          end
          d.path = path.join("/")
          d
        end
      end
    end
  end
end
