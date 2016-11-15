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
    end
  end
end
