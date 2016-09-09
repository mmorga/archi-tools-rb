# frozen_string_literal: true
module Archimate
  module Diff
    class Context
      attr_reader :model1, :model2

      def initialize(model1, model2)
        @model1 = model1
        @model2 = model2
        @path_stack = ["#{@model1.class.name.split('::').last}<#{model1.id}>"]
        @diffs = []
      end

      def diffs
        yield self
        @diffs.flatten
      end

      def in(differ, sym)
        @path_stack.push sym
        @diffs << apply_context(differ.diffs(model1.send(sym), model2.send(sym)))
        @path_stack.pop
      end

      def path_str
        @path_stack.join("/")
      end

      def apply_context(diffs)
        diffs.map do |d|
          d.entity = path_str + (d.entity.nil? ? "" : "/#{d.entity}")
          d
        end
      end
    end
  end
end
