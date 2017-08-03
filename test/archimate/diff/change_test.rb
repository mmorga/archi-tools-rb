# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ChangeTest < Minitest::Test
      attr_accessor :from_model
      attr_accessor :to_model

      def setup
        skip("Diff re-write")
        @from_model = build_model
        @to_model = @from_model.with(name: @from_model.name + "-changed")
        @subject = Change.new(
          ArchimateNodeAttributeReference.new(to_model, :name),
          ArchimateNodeAttributeReference.new(from_model, :name)
        )
      end

      def test_to_s
        skip("Diff rewrite")
        assert_equal(
          Color.uncolor("CHANGE: #{@from_model} name changed to #{@to_model.name}"),
          Color.uncolor(@subject.to_s)
        )
      end

      def test_apply
        skip("Diff rewrite")
        target = @from_model.clone

        @subject.apply(target)

        assert_equal @to_model.name, target.name
      end
    end
  end
end
