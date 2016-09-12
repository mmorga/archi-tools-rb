# frozen_string_literal: true
module Archimate
  module Diff
    class Context
      attr_reader :model1, :model2, :path_stack

      def initialize(model1, model2, path = [])
        @model1 = model1
        @model2 = model2
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

      def diffs(differ)
        @diffs << differ.diffs(self)
        @diffs.flatten.uniq
      end

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
            if d.entity.is_a?(Fixnum)
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
