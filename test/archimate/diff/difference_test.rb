# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DifferenceTest < Minitest::Test
      attr_accessor :model, :to_model

      def setup
        @model = build_model(with_relationships: 2, with_folders: 2)
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
        ["Model<abcd1234>/diagrams/1234abcd",
         "Model<3ada020a>/diagrams/1d371383"].each do |entity|
          diff = Change.new(entity, model, to_model, "Old Label", "New Label")
          assert diff.diagram?
        end
      end

      def test_diagram_fail_cases
        ["Model<abcd1234>/elements/1234abcd/label"].each do |entity|
          diff = Change.new(entity, model, to_model, "Old Label", "New Label")
          refute diff.diagram?
        end
      end

      def test_in_diagram?
        ["Model<abcd1234>/diagrams/1234abcd/name"].each do |entity|
          diff = Change.new(entity, model, to_model, "Old Label", "New Label")
          assert diff.in_diagram?
        end
      end

      def test_diagram_id
        [
          Insert.new("Model<abcd1234>/diagrams/1234abcd/children/726381", model, "new"),
          Change.new("Model<abcd1234>/diagrams/1234abcd", model, to_model, "old", "new"),
          Delete.new("Model<abcd1234>/diagrams/1234abcd/children/3439023/source_connection/384793837", model, "old")
        ].each do |diff|
          assert_equal "1234abcd", diff.diagram_id, "Expected to find diagram id for #{diff.path}"
        end

        [
          Change.new("Model<abcd1234>/label", model, to_model, "old", "new"),
          Change.new("Model<abcd1234>/elements/837483723/label", model, to_model, "old", "new")
        ].each do |diff|
          assert_nil diff.diagram_id, "Expected to not find diagram id for #{diff.path}"
        end
      end

      def test_in_diagram_fail_cases
        ["Model<abcd1234>/elements/1234abcd/label"].each do |entity|
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
        diagram = model.diagrams.first[1]
        diff = Change.new("Model<#{model.id}>/diagrams/#{diagram.id}/name", model, model, diagram.name, diagram.name + "changed")
        m2, remaining_path = diff.diagram_and_remaining_path(model)
        assert_equal diagram, m2
        assert_equal "/name", remaining_path
      end

      def test_relationship_and_remaining_path
        relationship = model.relationships.first[1]
        diff = Change.new("Model<#{model.id}>/relationships/#{relationship.id}/name", model, model, relationship.name, relationship.name + "changed")
        m2, remaining_path = diff.relationship_and_remaining_path(model)
        assert_equal relationship, m2
        assert_equal "/name", remaining_path
      end

      def test_element_and_remaining_path
        element = model.elements.first[1]
        diff = Change.new("Model<#{model.id}>/elements/#{element.id}/name", model, model, element.name, element.name + "changed")
        m2, remaining_path = diff.element_and_remaining_path(model)
        assert_equal element, m2
        assert_equal "/name", remaining_path
      end

      def test_folder_and_remaining_path
        folder = model.folders.first[1]
        diff = Change.new("Model<#{model.id}>/folders/#{folder.id}/name", model, model, folder.name, folder.name + "changed")
        m2, remaining_path = diff.folder_and_remaining_path(model)
        assert_equal folder, m2
        assert_equal "/name", remaining_path
      end

      def test_folder_and_remaining_path_with_nested_folders
        inner_folder = build_folder
        outer_folder = build_folder(folders: { inner_folder.id => inner_folder })
        model = build_model(folders: { outer_folder.id => outer_folder })
        diff = Change.new(
          "Model<#{model.id}>/folders/#{outer_folder.id}/folders/#{inner_folder.id}/name",
          model,
          model,
          inner_folder.name,
          inner_folder.name + "changed"
        )
        m2, remaining_path = diff.folder_and_remaining_path(model)
        assert_equal inner_folder, m2
        assert_equal "/name", remaining_path

        diff = Change.new(
          "Model<#{model.id}>/folders/#{outer_folder.id}/name",
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
