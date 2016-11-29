# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class InsertTest < Minitest::Test
      def setup
        @model = build_model(with_elements: 1)
        @subject = Insert.new(@model, "name")
      end

      def test_insert
        assert_equal @model, @subject.to_element
        assert_equal "name", @subject.sub_path
      end

      def test_to_s
        assert_equal(
          HighLine.uncolor("INSERT: name into #{@model}"),
          HighLine.uncolor(@subject.to_s)
        )
      end

      def test_to_s_for_struct
        @subject = Insert.new(@model.elements.first)

        assert_equal(
          HighLine.uncolor("INSERT: #{@model.elements.first} into #{@model}"),
          HighLine.uncolor(@subject.to_s)
        )
      end
    end
  end
end
