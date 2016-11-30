# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DeleteTest < Minitest::Test
      def setup
        @model = build_model(with_elements: 1)
        @subject = Delete.new(@model, "name")
      end

      def test_delete
        assert_equal @model, @subject.from_element
        assert_equal "name", @subject.sub_path
      end

      def test_to_s
        assert_equal(
          HighLine.uncolor("DELETE: name from #{@model}"),
          HighLine.uncolor(@subject.to_s)
        )
      end

      def test_to_s_for_struct
        @subject = Delete.new(@model.elements.first)

        assert_equal(
          HighLine.uncolor("DELETE: #{@model.elements.first} from #{@model}"),
          HighLine.uncolor(@subject.to_s)
        )
      end

      def test_apply
        target = @model.clone

        @subject.apply(target)

        assert_nil target.name
      end
    end
  end
end
