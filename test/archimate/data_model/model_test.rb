# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ModelTest < Minitest::Test
      def test_create
        model = Model.create(id: "123", name: "my model", documentation: %w(documentation1 documentation2))
        assert_equal "123", model.id
        assert_equal "my model", model.name
        assert_equal %w(documentation1 documentation2), model.documentation
      end

      def test_equality_operator
        m1 = build_model(with_elements: 3)
        m2 = m1.dup
        assert_equal m1, m2
      end

      def test_equality_operator_false
        m1 = build_model(with_elements: 3)
        m2 = m1.with(name: "felix")
        refute_equal m1, m2
      end

      def test_find_folder
        inner_folder = build_folder
        outer_folder = build_folder(folders: { inner_folder.id => inner_folder })
        model = build_model(folders: { outer_folder.id => outer_folder })
        assert_equal outer_folder, model.find_folder(outer_folder.id)
        assert_equal inner_folder, model.find_folder(inner_folder.id)
      end
    end
  end
end
