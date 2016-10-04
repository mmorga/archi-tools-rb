# frozen_string_literal: true
module Archimate
  module Diff
    class Context
      attr_reader :base, :local, :path_stack

      def initialize(base, local, path = [])
        @base = base
        @local = local
        raise TypeError, "Both models must be the same type" unless base.nil? || local.nil? || base.class == local.class
        @path_stack = Array(path)
        if @path_stack.empty?
          m = @base || @local
          unless m.nil? || m.is_a?(String)
            root = m.class.name.split('::').last
            root += "<#{m.id}>" if m.respond_to?(:id)
            @path_stack << root
          end
        end
      end

      def diffs
        return [] if base == local
        return [Difference.insert(path_str, local)] if base.nil?
        return [Difference.delete(path_str, base)] if local.nil?

        if base.is_a?(Dry::Struct::Value)
          base.instance_variables.reject { |i| i == :@schema }.each_with_object([]) do |i, a|
            @path_stack.push i.to_s.delete('@')
            a.concat(
              apply_context(
                Context.new(base.instance_variable_get(i), local.instance_variable_get(i)).diffs
              )
            )
            @path_stack.pop
          end
        elsif base.is_a?(Hash) # TODO: Refactor
          diff_list = []
          base.each do |id, el|
            diff_list << Context.new(el, local[id], [id]).diffs if local.include?(id) && el != local[id]
            diff_list << Difference.delete(id, el) unless local.include?(id)
          end
          local.each do |id, el|
            diff_list << Difference.insert(id, el) unless base.include?(id)
          end
          diff_list.flatten
        elsif base.is_a?(Array)
          diff_list = []
          base.each_with_index do |item, idx|
            diff_list << Difference.delete(idx, item) unless local.include?(item)
          end
          local.each_with_index do |item, idx|
            diff_list << Difference.insert(idx, item) { |d| d.entity = idx } unless base.include?(item)
          end
          diff_list
        else
          [Difference.change(path_str, base, local)]
        end
      end

      private

      def path_str
        @path_stack.compact.delete_if(&:empty?).join("/")
      end

      def apply_context(diffs)
        diffs.map do |d|
          path = @path_stack.dup
          unless d.entity.nil?
            if d.entity.is_a?(Integer)
              path << "[#{d.entity}]"
            else
              path << d.entity.to_s unless d.entity.to_s.empty?
            end
          end
          d.entity = path.join("/")
          d
        end
      end
    end
  end
end
