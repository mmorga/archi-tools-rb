# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class ModelTest < Minitest::Test
      def test_new
        model = Model.new("123", "my model") do |m|
          m.documentation = %w(documentation1 documentation2)
        end
        assert_equal "123", model.id
        assert_equal "my model", model.name
        assert_equal %w(documentation1 documentation2), model.documentation
      end

      def test_add_element
        model = build_model(with_elements: 3)
        el_count = model.elements.size
        expected = build_element
        model.add_element(expected)
        assert_equal el_count + 1, model.elements.size
        assert_equal expected, model.elements[expected.id]
      end

      def test_equality_operator
        m1 = build_model(with_elements: 3)
        m2 = m1.dup
        assert_equal m1, m2
      end

      def test_equality_operator_false
        m1 = build_model(with_elements: 3)
        m2 = m1.dup
        m2.name = "felix"
        refute_equal m1, m2
      end

      def xtest_apply_diff_insert
        fail "noprah!"
      end
    end
  end
end
