# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DifferentiableTest < Minitest::Test
      class SimpleDifferentiable
        include Comparison
        include Differentiable

        model_attr :id
        model_attr :name
        model_attr :age

        def initialize(id:, name:, age:)
          @id = id
          @name = name
          @age = age
        end
      end

      class ComposingDifferentiable
        include Comparison
        include Differentiable

        model_attr :name
        model_attr :simple

        def initialize(name:, simple:)
          @name = name
          @simple = simple
        end
      end

      class ReferencingDifferentiable
        include Comparison
        include Differentiable

        model_attr :id
        model_attr :ref, comparison_attr: :id

        def initialize(id:, ref:)
          @id = id
          @ref = ref
        end
      end

      def setup
        @simple1 = SimpleDifferentiable.new(id: 1, name: "frank", age: 21)
        @simple2 = SimpleDifferentiable.new(id: 1, name: "bob", age: 21)
        @simple3 = SimpleDifferentiable.new(id: 1, name: "sally", age: 32)
        @simple4 = SimpleDifferentiable.new(id: 1, name: nil, age: 21)
        @composed1 = ComposingDifferentiable.new(name: "bach", simple: @simple1)
        @composed2 = ComposingDifferentiable.new(name: "homme", simple: @simple2)
        @ref1 = ReferencingDifferentiable.new(id: 1, ref: @simple1)
        @ref2 = ReferencingDifferentiable.new(id: 1, ref: @simple2)
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
        assert_equal [Insert.new(:name, "frank")], @simple4.diff(@simple1)
        assert_equal [Delete.new(:name)], @simple1.diff(@simple4)
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
        assert_equal @simple1, @simple4.patch([Insert.new(:name, "frank")])
        assert_equal @simple4, @simple1.patch([Delete.new(:name)])
      end

      def test_composed_diff
        assert_equal(
          [
            Change.new(:name, "bach", "homme"),
            Change.new([:simple, :name], "frank", "bob")
          ],
          @composed1.diff(@composed2)
        )
      end

      def test_composed_patch
        assert_equal(
          @composed2,
          @composed1.patch(
            [
              Change.new(:name, "bach", "homme"),
              Change.new([:simple, :name], "frank", "bob")
            ]
          )
        )
      end

      def test_referenceable
        assert_empty @ref1.diff(@ref2)
      end
    end
  end
end
