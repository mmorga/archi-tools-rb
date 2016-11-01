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
          unless m.nil? || m.is_a?(String)
            root = m.class.name.split('::').last
            root += "<#{m.id}>" if m.respond_to?(:id)
            @path_stack << root
          end
        end
      end

      # TODO: Refactor this. Can be a lot more clear.
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
        elsif base.is_a?(Hash) # TODO: Refactor
          diff_list = []
          base.each do |id, el|
            diff_list << Context.new(base_model, local_model, el, local[id], [id]).diffs if local.include?(id) && el != local[id]
            diff_list << Delete.new(id, base_model, el) unless local.include?(id)
          end
          local.each do |id, el|
            diff_list << Insert.new(id, local_model, el) unless base.include?(id)
          end
          diff_list.flatten
        elsif base.is_a?(Array)
          diff_list = []
          base.each_with_index do |item, idx|
            diff_list << Delete.new(idx, base_model, item) unless local.include?(item)
          end
          local.each_with_index do |item, idx|
            diff_list << Insert.new(idx, local_model, item) { |d| d.path = idx } unless base.include?(item)
          end
          diff_list
        else
          [Change.new(path_str, base_model, local_model, base, local)]
        end
      end

      private

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
