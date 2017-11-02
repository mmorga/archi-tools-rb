# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class ComplexComparison
      include Comparison

      model_attr :shape
      model_attr :size, writable: true
      model_attr :ref, comparison_attr: :name
    end

    RefThing = Struct.new(:name, :value) do
      include Referenceable
    end

    class ComparisonTest < Minitest::Test
      def setup
        @ref_thing1 = RefThing.new(1, "thing")
        @subject1 = ComplexComparison.new(shape: "circle", size: 12, ref: @ref_thing1)
        @subject2 = ComplexComparison.new(shape: "circle", size: 12, ref: @ref_thing1)
        @subject3 = ComplexComparison.new(shape: "circle", size: 12, ref: RefThing.new(1, "nothing"))
      end

      def test_eqleql
        assert_equal @subject1, @subject2
        assert_equal @subject1, @subject3
        assert_equal @subject1.ref, @subject2.ref
        refute_equal @subject1.ref, @subject3.ref
      end

      def test_writeable
        assert_respond_to @subject1, :size=
        @subject1.size = 42
        assert_equal 42, @subject1.size
      end

      def test_hash
        assert_equal ComplexComparison.hash ^ "circle".hash ^ 12.hash ^ RefThing.new(1, "thing").hash, @subject1.hash
      end

      def test_to_h
        assert_equal(
          {
            shape: "circle",
            size: 12,
            ref: RefThing.new(1, "thing")
          }, @subject1.to_h
        )
      end

      def test_dig
        assert_equal "thing", @subject1.dig(:ref, :value)
      end

      def test_referenceable_integration
        assert_equal 2, @ref_thing1.references.size
        assert_includes @ref_thing1.references, @subject1
        assert_includes @ref_thing1.references, @subject2
      end
    end
  end
end
