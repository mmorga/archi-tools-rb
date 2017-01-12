# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class MoveTest < Minitest::Test
      attr_accessor :from_model
      attr_accessor :to_model

      def setup
        @from_model = build_model(with_elements: 3)
        @to_model = @from_model.with(
          elements: [
            @from_model.elements[2],
            @from_model.elements[0],
            @from_model.elements[1]
          ]
        )
        @subject = Move.new(
          ArchimateArrayReference.new(to_model.elements, 0),
          ArchimateArrayReference.new(from_model.elements, 2)
        )
      end

      def test_to_s
        assert_equal(
          HighLine.uncolor("MOVE: #{@from_model}/elements #{@subject.target.value} moved to 0"),
          HighLine.uncolor(@subject.to_s)
        )
      end

      def test_apply
        target = @from_model.clone

        @subject.apply(target)

        assert_equal @to_model.name, target.name
      end

      def test_move?
        assert @subject.move?
      end

      def test_kind
        assert_equal "Move", @subject.kind
      end
    end
  end
end
