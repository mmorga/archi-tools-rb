# frozen_string_literal: true
module Archimate
  module Diff
    class Context
      attr_reader :model1, :model2, :path_stack

      def initialize(model1, model2, path = [])
        @model1 = model1
        @model2 = model2
        # raise ArgumentError, "Both models can't be nil" if @model1.nil? && @model2.nil?
        raise TypeError, "Both models must be the same type" unless model1.nil? || model2.nil? || model1.class == model2.class
        @path_stack = Array(path) # path.empty? ? ["#{}] :
        if @path_stack.empty?
          m = @model1 || @model2
          unless m.nil? || m.is_a?(String)
            root = m.class.name.split('::').last
            root += "<#{m.id}>" if m.respond_to?(:id)
            @path_stack << root
          end
        end
        @diffs = []
      end

      def diffs
        return [] if model1 == model2
        return [Difference.insert(path_str, model2)] if model1.nil?
        return [Difference.delete(path_str, model1)] if model2.nil?

        if model1.is_a?(Dry::Struct::Value)
          model1.instance_variables.reject { |i| i == :@schema }.each_with_object([]) do |i, a|
            @path_stack.push i.to_s.delete('@')
            a.concat(
              apply_context(
                Context.new(model1.instance_variable_get(i), model2.instance_variable_get(i)).diffs
              )
            )
            @path_stack.pop
          end
        elsif model1.is_a?(Hash) # TODO: Refactor
          diff_list = []
          model1.each do |id, el|
            diff_list << Context.new(el, model2[id], [id]).diffs if model2.include?(id) && el != model2[id]
            diff_list << Difference.delete(id, el) unless model2.include?(id)
          end
          model2.each do |id, el|
            diff_list << Difference.insert(id, el) unless model1.include?(id)
          end
          diff_list.flatten
        elsif model1.is_a?(Array)
          diff_list = []
          model1.each_with_index do |item, idx|
            diff_list << Difference.delete(idx, item) unless model2.include?(item)
          end
          model2.each_with_index do |item, idx|
            diff_list << Difference.insert(idx, item) { |d| d.entity = idx } unless model1.include?(item)
          end
          diff_list
        else
          [Difference.change(path_str, model1, model2)]
        end
      end

      private

      # This computes the diffs at the model level for this Context
      def diffs_old(differ)
        @diffs << differ.diffs(self)
        @diffs.flatten.uniq
      end

      # This computest the diffs at the model child level for this Context
      # This is called by the *Diff.diffs method
      def diff(differ, sym)
        @path_stack.push sym
        @diffs << apply_context(differ.diffs(Context.new(model1.send(sym), model2.send(sym))))
        @path_stack.pop
        @diffs.flatten
      end

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
