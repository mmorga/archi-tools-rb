# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DifferenceTest < Minitest::Test
      attr_accessor :model, :to_model

      def setup
        @model = build_model(with_relationships: 2, with_folders: 2, with_diagrams: 1)
        @to_model = build_model
      end

      def test_with
        diff = Change.new("Model<abcd1234>/elements/1234abcd/label", model, to_model, "Old Label", "New Label")
        actual = diff.with(path: "elements/1234abcd/label")
        assert_equal "elements/1234abcd/label", actual.path
        refute_equal diff.path, actual.path
        assert_equal "Old Label", actual.from
        assert_equal "New Label", actual.to
      end

      def test_diagram?
        ["Model<abcd1234>/diagrams/[0]",
         "Model<3ada020a>/diagrams/[1]"].each do |entity|
          diff = Change.new(entity, model, to_model, "Old Label", "New Label")
          assert diff.diagram?
        end
      end

      def test_diagram_fail_cases
        ["Model<abcd1234>/elements/[1]/label"].each do |entity|
          diff = Change.new(entity, model, to_model, "Old Label", "New Label")
          refute diff.diagram?
        end
      end

      def test_in_diagram?
        ["Model<abcd1234>/diagrams/[1]/name"].each do |entity|
          diff = Change.new(entity, model, to_model, "Old Label", "New Label")
          assert diff.in_diagram?
        end
      end

      def test_diagram_idx
        [
          Insert.new("Model<abcd1234>/diagrams/[3]/children/[0]", model, "new"),
          Change.new("Model<abcd1234>/diagrams/[3]", model, to_model, "old", "new"),
          Delete.new("Model<abcd1234>/diagrams/[3]/children/[0]/source_connection/[0]", model, "old")
        ].each do |diff|
          assert_equal 3, diff.diagram_idx, "Expected to find diagram id for #{diff.path}"
        end

        [
          Change.new("Model<abcd1234>/label", model, to_model, "old", "new"),
          Change.new("Model<abcd1234>/elements/[0]/label", model, to_model, "old", "new")
        ].each do |diff|
          assert_nil diff.diagram_idx, "Expected to not find diagram id for #{diff.path}"
        end
      end

      def test_in_diagram_fail_cases
        ["Model<abcd1234>/elements/[0]/label"].each do |entity|
          diff = Change.new(entity, model, to_model, "Old Label", "New Label")
          refute diff.in_diagram?
        end
      end

      def test_model_and_remaining_path
        diff = Change.new("Model<#{model.id}>/name", model, model, model.name, model.name + "changed")
        m2, remaining_path = diff.model_and_remaining_path(model)
        assert_equal model, m2
        assert_equal "/name", remaining_path
      end

      def test_diagram_and_remaining_path
        diagram = model.diagrams.first
        diff = Change.new("Model<#{model.id}>/diagrams/[0]/name", model, model, diagram.name, diagram.name + "changed")

        m2, remaining_path = diff.diagram_and_remaining_path(model)

        assert_equal diagram, m2
        assert_equal "/name", remaining_path
      end

      def test_relationship_and_remaining_path
        relationship = model.relationships.first
        diff = Change.new("Model<#{model.id}>/relationships/[0]/name", model, model, relationship.name, relationship.name + "changed")

        m2, remaining_path = diff.relationship_and_remaining_path(model)

        assert_equal relationship, m2
        assert_equal "/name", remaining_path
      end

      def test_element_and_remaining_path
        element = model.elements.first
        diff = Change.new("Model<#{model.id}>/elements/[0]/name", model, model, element.name, element.name + "changed")

        m2, remaining_path = diff.element_and_remaining_path(model)

        assert_equal element, m2
        assert_equal "/name", remaining_path
      end

      def test_folder_and_remaining_path
        folder = model.folders.first
        diff = Change.new("Model<#{model.id}>/folders/[0]/name", model, model, folder.name, folder.name + "changed")

        m2, remaining_path = diff.folder_and_remaining_path(model)

        assert_equal folder, m2
        assert_equal "/name", remaining_path
      end

      def test_folder_and_remaining_path_with_nested_folders_and_last_folder_child
        inner_folder = build_folder
        outer_folder = build_folder(folders: [inner_folder])
        model = build_model(folders: [outer_folder])
        diff = Change.new(
          "Model<#{model.id}>/folders/[0]/folders/[0]/name",
          model,
          model,
          inner_folder.name,
          inner_folder.name + "changed"
        )

        m2, remaining_path = diff.folder_and_remaining_path(model)

        assert_equal inner_folder, m2
        assert_equal "/name", remaining_path
      end

      def test_folder_and_remaining_path_with_nested_folders_and_first_folder_child
        inner_folder = build_folder
        outer_folder = build_folder(folders: [inner_folder])
        model = build_model(folders: [outer_folder])
        diff = Change.new(
          "Model<#{model.id}>/folders/[0]/name",
          model,
          model,
          outer_folder.name,
          outer_folder.name + "changed"
        )

        m2, remaining_path = diff.folder_and_remaining_path(model)

        assert_equal outer_folder, m2
        assert_equal "/name", remaining_path
      end

      def test_change
        folder = model.folders.first
        change_diff = Change.new("Model<#{model.id}>/folders/[0]/name", model, model, folder.name, folder.name + "changed")
        insert_diff = Insert.new("Model<abcd1234>/diagrams/[3]/children/[0]", model, "new")

        assert change_diff.change?
        refute change_diff.insert?

        assert insert_diff.insert?
        refute insert_diff.change?
      end

      def test_describeable_parent_for_folder
        folder_diff = Delete.new("Model<#{model.id}>/folders/[0]/name", model, model.folders.first.name)
        assert_equal [model.folders.first, "/name"], folder_diff.describeable_parent(model)
      end

      def test_describeable_parent_for_element
        diff = Delete.new("Model<#{model.id}>/elements/[0]/label", model, model.elements.first.label)
        assert_equal [model.elements.first, "/label"], diff.describeable_parent(model)
      end

      def test_describeable_parent_for_relationship
        diff = Delete.new("Model<#{model.id}>/relationships/[0]/name", model, model.relationships.first.name)
        assert_equal [model.relationships.first, "/name"], diff.describeable_parent(model)
      end

      def test_sort
        paths = [
          "Model<bee5a0a7>/diagrams/[52]/children/[0]/bounds/x",
          "Model<bee5a0a7>/diagrams/[52]/children/[1]/bounds/width",
          "Model<bee5a0a7>/diagrams/[52]/children/[1]/bounds/x",
          "Model<bee5a0a7>/diagrams/[52]/children/[1]/bounds/y",
          "Model<bee5a0a7>/diagrams/[52]/children/[2]/bounds/width",
          "Model<bee5a0a7>/diagrams/[52]/children/[2]/target_connections",
          "Model<bee5a0a7>/diagrams/[64]/children/[0]/children/[1]/archimate_element",
          "Model<bee5a0a7>/diagrams/[74]/children/[2]/children/[2]/archimate_element",
          "Model<bee5a0a7>/diagrams/[90]/children/[7]/archimate_element",
          "Model<bee5a0a7>/diagrams/[90]/children/[0]/archimate_element",
          "Model<bee5a0a7>/elements/[1032]/label",
          "Model<bee5a0a7>/elements/[135]/label",
          "Model<bee5a0a7>/elements/[1430]/label",
          "Model<bee5a0a7>/elements/[3]/label",
          "Model<bee5a0a7>/relationships/[1009]/source",
          "Model<bee5a0a7>/relationships/[100]/target",
          "Model<bee5a0a7>/relationships/[4]/source",
          "Model<bee5a0a7>/diagrams/[121]/children/[4]/children/[0]/archimate_element",
          "Model<bee5a0a7>/diagrams/[121]/children/[4]/archimate_element",
          "Model<bee5a0a7>/relationships/[5689]",
          "Model<bee5a0a7>/folders/[8]/items/[46]",
          "Model<bee5a0a7>/folders/[8]/items/[35]",
          "Model<bee5a0a7>/folders/[8]/folders/[9]/folders/[2]",
          "Model<bee5a0a7>/folders/[8]/folders/[6]/folders/[5]",
          "Model<bee5a0a7>/folders/[8]/folders/[6]/folders/[4]",
          "Model<bee5a0a7>/folders/[8]/folders/[37]",
          "Model<bee5a0a7>/folders/[8]/folders/[33]/items/[2]",
          "Model<bee5a0a7>/folders/[8]/folders/[1]/folders/[1]/folders/[0]",
          "Model<bee5a0a7>/folders/[7]/items/[28]",
          "Model<bee5a0a7>/folders/[6]/items/[6978]",
          "Model<bee5a0a7>/folders/[6]/items/[6976]",
          "Model<bee5a0a7>/elements/[1483]"
        ]
        expected_paths = [
          "Model<bee5a0a7>/elements/[3]/label",
          "Model<bee5a0a7>/elements/[135]/label",
          "Model<bee5a0a7>/elements/[1032]/label",
          "Model<bee5a0a7>/elements/[1430]/label",
          "Model<bee5a0a7>/elements/[1483]",
          "Model<bee5a0a7>/relationships/[4]/source",
          "Model<bee5a0a7>/relationships/[100]/target",
          "Model<bee5a0a7>/relationships/[1009]/source",
          "Model<bee5a0a7>/relationships/[5689]",
          "Model<bee5a0a7>/diagrams/[52]/children/[0]/bounds/x",
          "Model<bee5a0a7>/diagrams/[52]/children/[1]/bounds/width",
          "Model<bee5a0a7>/diagrams/[52]/children/[1]/bounds/x",
          "Model<bee5a0a7>/diagrams/[52]/children/[1]/bounds/y",
          "Model<bee5a0a7>/diagrams/[52]/children/[2]/bounds/width",
          "Model<bee5a0a7>/diagrams/[52]/children/[2]/target_connections",
          "Model<bee5a0a7>/diagrams/[64]/children/[0]/children/[1]/archimate_element",
          "Model<bee5a0a7>/diagrams/[74]/children/[2]/children/[2]/archimate_element",
          "Model<bee5a0a7>/diagrams/[90]/children/[0]/archimate_element",
          "Model<bee5a0a7>/diagrams/[90]/children/[7]/archimate_element",
          "Model<bee5a0a7>/diagrams/[121]/children/[4]/archimate_element",
          "Model<bee5a0a7>/diagrams/[121]/children/[4]/children/[0]/archimate_element",
          "Model<bee5a0a7>/folders/[6]/items/[6976]",
          "Model<bee5a0a7>/folders/[6]/items/[6978]",
          "Model<bee5a0a7>/folders/[7]/items/[28]",
          "Model<bee5a0a7>/folders/[8]/folders/[1]/folders/[1]/folders/[0]",
          "Model<bee5a0a7>/folders/[8]/folders/[6]/folders/[4]",
          "Model<bee5a0a7>/folders/[8]/folders/[6]/folders/[5]",
          "Model<bee5a0a7>/folders/[8]/folders/[9]/folders/[2]",
          "Model<bee5a0a7>/folders/[8]/folders/[33]/items/[2]",
          "Model<bee5a0a7>/folders/[8]/folders/[37]",
          "Model<bee5a0a7>/folders/[8]/items/[35]",
          "Model<bee5a0a7>/folders/[8]/items/[46]"
        ]
        diffs = paths.map { |p| Delete.new(p, model, "n/a") }

        result = diffs.sort

        assert_equal expected_paths, result.map(&:path)
      end

      def test_sort_bounds_attributes
        d1 = Delete.new("Model<bee5a0a7>/diagrams/[52]/children/[0]/bounds/x", model, "n/a")
        d2 = Delete.new("Model<bee5a0a7>/diagrams/[52]/children/[1]/bounds/width", model, "n/a")
        expected = [d1, d2]

        assert_equal expected, [d1, d2].sort
        assert_equal expected, [d2, d1].sort
      end

      def test_sort_elements_index
        d1 = Delete.new("Model<bee5a0a7>/elements/[1430]/label", model, "n/a")
        d2 = Delete.new("Model<bee5a0a7>/elements/[3]/label", model, "n/a")
        expected = [d2, d1]

        assert_equal expected, [d1, d2].sort
        assert_equal expected, [d2, d1].sort
      end
    end
  end
end
