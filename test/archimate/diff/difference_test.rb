# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DifferenceTest < Minitest::Test
      attr_accessor :model, :to_model

      def setup
        @model = build_model
        @to_model = build_model
      end

      # def test_with
      #   diff = Change.new("Model<abcd1234>/elements/1234abcd/label", model, to_model, "Old Label", "New Label")
      #   actual = diff.with(entity: "elements/1234abcd/label")
      #   assert_equal "elements/1234abcd/label", actual.entity
      #   refute_equal diff.path, actual.entity
      #   assert_equal "Old Label", actual.from
      #   assert_equal "New Label", actual.to
      # end

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
    end
  end
end
