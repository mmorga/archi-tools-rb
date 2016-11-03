# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ModelTest < Minitest::Test
      def setup
        @subject = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
      end

      def test_create
        expected = build_documentation_list(count: 2)
        model = Model.create(id: "123", name: "my model", documentation: expected)
        assert_equal "123", model.id
        assert_equal "my model", model.name
        assert_equal expected, model.documentation
      end

      def test_build_model
        m = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        assert_equal 4, m.elements.size
        assert_equal 2, m.relationships.size
        assert_equal 2, m.diagrams.size
        assert_equal 4, Model.flat_folder_hash(m.folders).size

        assert m.elements.all? { |_id, i| i.parent_id == m.id }
        assert m.relationships.all? { |_id, i| i.parent_id == m.id }
        assert m.diagrams.all? { |_id, i| i.parent_id == m.id }
        assert m.folders.all? { |_id, i| i.parent_id == m.id }
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

      def test_entity_id_lookup
        m = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        assert_equal 2, m.relationships.size
        assert_equal 2, m.diagrams.size
        assert_equal 4, m.elements.size
        assert_equal 4, Model.flat_folder_hash(m.folders).size
        m.relationships.all? { |id, r| assert_equal r, m.lookup(id) }
        m.elements.all? { |id, r| assert_equal r, m.lookup(id) }
        m.folders.all? { |id, r| assert_equal r, m.lookup(id) }
      end

      def test_clone
        s2 = @subject.clone
        assert_equal @subject, s2
        refute_equal @subject.object_id, s2.object_id
      end
    end
  end
end
