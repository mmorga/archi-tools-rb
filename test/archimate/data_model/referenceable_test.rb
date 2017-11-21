# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class ReferenceableTest < Minitest::Test
      def test_super_simple
        model = build_model(with_elements: 2, relationships: [], diagrams: [], organizations: [])
        el1 = model.elements[0]
        el2 = model.elements[1]
        el2.replace_with(el1)

        assert_includes model.elements, el1
        refute_includes model.elements, el2
        assert_equal 1, model.elements.size
      end

      def test_with_a_relationship
        el1, el2, el3 = elements = build_element_list(with_elements: 3)
        rel = build_relationship(source: el2, target: el3)
        model = build_model(elements: elements, relationships: [rel], diagrams: [], organizations: [])
        assert(model.elements.all? { |el| el.references.include?(model) })

        el2.replace_with(el1)

        assert_equal el1, rel.source
        assert_includes model.elements, el1
        refute_includes model.elements.map(&:to_s), el2.to_s
        assert_equal 2, model.elements.size
        assert_equal [rel], model.relationships
      end
    end
  end
end
