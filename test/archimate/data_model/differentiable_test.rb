# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DifferentiableTest < Minitest::Test
      class SimpleDifferentiable
        include Comparison
        include Differentiable

        model_attr :name
        model_attr :age

        def initialize(name:, age:)
          @name = name
          @age = age
        end
      end

      def setup
        @simple1 = SimpleDifferentiable.new(name: "frank", age: 21)
        @simple2 = SimpleDifferentiable.new(name: "bob", age: 21)
        @simple3 = SimpleDifferentiable.new(name: "sally", age: 32)
      end

      def test_simple_diff
        assert_empty @simple1.diff(@simple1.dup)
        assert_equal [Change.new(:name, "frank", "bob")], @simple1.diff(@simple2)
        assert_equal(
          [
            Change.new(:name, "frank", "sally"),
            Change.new(:age, 21, 32),
          ],
          @simple1.diff(@simple3)
        )
      end

      def test_simple_patch_empty_set
        assert_equal @simple1, @simple1.patch([])
        refute_same @simple1, @simple1.patch([])
      end

      def test_simple_patch
        assert_equal @simple2, @simple1.patch(Change.new(:name, "frank", "bob"))
        assert_equal @simple3, @simple1.patch([
            Change.new(:name, "frank", "sally"),
            Change.new(:age, 21, 32),
          ])
      end
    end
  end
end
