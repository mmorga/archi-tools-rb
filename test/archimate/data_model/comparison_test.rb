# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ComplexComparison
      include Comparison

      model_attr :shape
      model_attr :size, writable: true
      model_attr :ref, comparison_attr: :name

      def initialize(shape, size, ref)
        @shape = shape
        @size = size
        @ref = ref
      end
    end

    RefThing = Struct.new(:name, :value)

    class ComparisonTest < Minitest::Test
      def setup
        @subject1 = ComplexComparison.new("circle", 12, RefThing.new(1, "thing"))
        @subject2 = ComplexComparison.new("circle", 12, RefThing.new(1, "thing"))
        @subject3 = ComplexComparison.new("circle", 12, RefThing.new(1, "nothing"))
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
        assert_equal({
            shape: "circle",
            size: 12,
            ref: RefThing.new(1, "thing")
          }, @subject1.to_h)
      end

      def test_dig
        assert_equal "thing", @subject1.dig(:ref, :value)
      end
    end
  end
end
