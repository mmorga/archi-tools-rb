# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class InsertTest < Minitest::Test
      using DataModel::DiffableArray

      def setup
        @model = build_model(with_elements: 1)
        @subject = Insert.new(ArchimateNodeAttributeReference.new(@model, :name))
      end

      def test_to_s
        assert_equal(
          HighLine.uncolor("INSERT: #{@subject.target} into #{@model}"),
          HighLine.uncolor(@subject.to_s)
        )
      end

      def test_to_s_for_struct
        @subject = Insert.new(ArchimateArrayReference.new(@model.elements, 0))

        assert_equal(
          HighLine.uncolor("INSERT: #{@model.elements.first} into #{@model}/elements"),
          HighLine.uncolor(@subject.to_s)
        )
      end

      def test_apply_primitive
        target = @model.with(name: "foobar")

        @subject.apply(target)

        assert_equal @model.name, target.name
      end

      def test_apply_insert_element_into_array
        base = build_model(with_elements: 1)
        inserted_element = build_element
        local = base.with(elements: base.elements + [inserted_element])
        inserted_element = local.lookup(inserted_element.id)
        subject = Insert.new(ArchimateArrayReference.new(local.elements, local.elements.index(inserted_element)))
        assert_equal local, inserted_element.in_model
        assert_same local.elements, inserted_element.parent

        merged = subject.apply(base.clone)

        assert_equal inserted_element, merged.elements.last
      end
    end
  end
end
