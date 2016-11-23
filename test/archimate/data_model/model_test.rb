# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ModelTest < Minitest::Test
      ELEMENT_COUNT = 4

      def setup
        @subject = build_model(with_relationships: 2, with_diagrams: 2, with_elements: ELEMENT_COUNT, with_folders: 4)
      end

      def test_create
        expected = build_documentation_list(count: 2)
        model = Model.create(id: "123", name: "my model", documentation: expected)
        assert_equal "123", model.id
        assert_equal "my model", model.name
        assert_equal expected, model.documentation
      end

      def test_build_model
        assert_equal 4, @subject.elements.size
        assert_equal 2, @subject.relationships.size
        assert_equal 2, @subject.diagrams.size
        assert_equal 4, Model.flat_folder_hash(@subject.folders).size

        assert @subject.elements.all? { |i| i.parent_id == @subject.id }
        assert @subject.relationships.all? { |i| i.parent_id == @subject.id }
        assert @subject.diagrams.all? { |i| i.parent_id == @subject.id }
        assert @subject.folders.all? { |i| i.parent_id == @subject.id }
      end

      def test_equality_operator
        m2 = @subject.clone
        assert_equal @subject, m2
      end

      def test_equality_operator_false
        m2 = @subject.with(name: "felix")
        refute_equal @subject, m2
      end

      def test_find_folder
        inner_folder = build_folder
        outer_folder = build_folder(folders: [inner_folder])
        model = build_model(folders: [outer_folder])
        assert_equal outer_folder, model.find_folder(outer_folder.id)
        assert_equal inner_folder, model.find_folder(inner_folder.id)
      end

      def test_lookup
        @subject.relationships.each { |r| assert_equal r, @subject.lookup(r.id) }
        @subject.elements.each { |e| assert_equal e, @subject.lookup(e.id) }
        @subject.folders.each { |f| assert_equal f, @subject.lookup(f.id) }
        @subject.diagrams.each { |d| assert_equal d, @subject.lookup(d.id) }
      end

      def test_clone
        s2 = @subject.clone
        assert_equal @subject, s2
        refute_equal @subject.object_id, s2.object_id
      end

      def test_insert_element
        m2 = @subject.insert_element(build_element)
        assert_kind_of Array, m2.elements
        assert m2.elements.all? { |e| e.is_a?(Element) }
      end

      def test_insert_element_replacing_element
        replaced_element = @subject.elements.first
        replacement_element = replaced_element.with(label: replaced_element.label + "-changed")
        refute_equal replaced_element, replacement_element

        m2 = @subject.insert_element(replacement_element)

        assert_equal @subject.elements.size, m2.elements.size
        assert_includes m2.elements, replacement_element
        refute_includes m2.elements, replaced_element
        assert_equal @subject.elements.index(replaced_element), m2.elements.index(replacement_element)
      end

      0.upto(ELEMENT_COUNT - 1) do |idx|
        define_method("test_delete_at_#{idx}") do
          expected_size = @subject.elements.size
          deleted_element = @subject.elements[idx]

          @subject.delete_at("Model<#{@subject.id}>/elements/[#{idx}]")

          refute_includes @subject.elements, deleted_element
          assert_nil @subject.elements[idx]
          assert_equal expected_size, @subject.elements.size
        end
      end

      def test_insert_at
        inserted_element = build_element
        expected_elements = @subject.elements.map(&:clone)
        # expected_elements.insert(2, inserted_element)
        expected_elements << inserted_element

        @subject.insert_at("Model<#{@subject.id}>/elements/[2]", inserted_element)

        assert_equal expected_elements, @subject.elements
        assert_includes @subject.elements, inserted_element
        assert_equal ELEMENT_COUNT + 1, @subject.elements.size
      end

      def test_application_components
        el = build_element(type: "ApplicationComponent")
        elements = @subject.elements + [el]
        model = @subject.with(elements: elements)
        expected = model.elements.select { |e| e.type == "ApplicationComponent" }

        assert_equal expected, model.application_components
      end

      def test_get_at_path
        result = @subject.get_at_path("Model<#{@subject.id}>/elements/[0]")

        assert_equal 3, result.size
        assert_equal @subject.elements[0], result[0]
        assert_equal 0, result[1]
        assert_equal @subject.elements, result[2]
      end

      def test_at_for_array_index
        assert_equal @subject.elements[0], @subject.at("Model<#{@subject.id}>/elements/[0]")
      end

      def test_at_for_item
        assert_equal @subject.elements[0].label, @subject.at("Model<#{@subject.id}>/elements/[0]/label")
      end
    end
  end
end
