# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class WithTest < Minitest::Test
      def test_with
        m = build_model
        m2 = m.with(name: m.name + "-changed")
        refute_equal m, m2
        m.comparison_attributes.reject { |a| a == :@name }.each do |a|
          assert_equal m.instance_variable_get(a), m2.instance_variable_get(a)
        end
      end

      def test_in_model
        m = build_model(with_elements: 3, with_relationships: 2, with_diagrams: 1)
        m.elements.each { |e| assert_equal m, e.in_model }
      end

      def test_parent
        m = build_model(with_elements: 3, with_relationships: 2, with_diagrams: 1)
        m.elements.each { |e| assert_equal m.id, e.parent_id }
        m.elements.each { |e| assert_equal m, e.parent }
      end
    end
  end
end
