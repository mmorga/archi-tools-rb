# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DifferenceTest < Minitest::Test
      attr_accessor :model, :to_model

      def setup
        @model = build_model(with_relationships: 2, with_folders: 2, with_diagrams: 2)
        @to_model = build_model
      end

      def test_change
        folder = model.folders.first
        remote = model.with(
          diagrams: [
            model.diagrams[0].with(
              children: [build_child] + model.diagrams[0].children
            )
          ]
        )

        change_diff = Change.new(ArchimateNodeAttributeReference.new(folder, :name), ArchimateNodeAttributeReference.new(folder, :name))
        insert_diff = Insert.new(ArchimateArrayReference.new(remote.diagrams[0].children, 0))

        assert change_diff.change?
        refute change_diff.insert?

        assert insert_diff.insert?
        refute insert_diff.change?
      end

      def xtest_sort
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
          "Model<bee5a0a7>/elements/[1032]/name",
          "Model<bee5a0a7>/elements/[135]/name",
          "Model<bee5a0a7>/elements/[1430]/name",
          "Model<bee5a0a7>/elements/[3]/name",
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
          "Model<bee5a0a7>/elements/[3]/name",
          "Model<bee5a0a7>/elements/[135]/name",
          "Model<bee5a0a7>/elements/[1032]/name",
          "Model<bee5a0a7>/elements/[1430]/name",
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
        bounds = model.diagrams.first.children.first.bounds
        d1 = Delete.new(ArchimateNodeAttributeReference.new(bounds, :x))
        d2 = Delete.new(ArchimateNodeAttributeReference.new(bounds, :width))
        expected = [d2, d1]

        assert_equal expected, [d1, d2].sort
        assert_equal expected, [d2, d1].sort
      end

      def test_sort_elements_index
        skip "sorting isn't working yet"
        d1 = Delete.new(ArchimateNodeAttributeReference.new(model.elements.last, :name))
        d2 = Delete.new(ArchimateNodeAttributeReference.new(model.elements.first, :name))
        expected = [d2, d1]

        assert_equal expected, [d1, d2].sort
        assert_equal expected, [d2, d1].sort
      end

      def test_path
        d1 = Delete.new(ArchimateNodeAttributeReference.new(model, :name))

        assert_equal("name", d1.path)
      end

      def test_bounds_path
        bounds = model.diagrams.first.children.first.bounds
        d1 = Delete.new(ArchimateNodeAttributeReference.new(bounds, :x))

        assert_equal(
          "diagrams/#{model.diagrams.first.id}/children/#{model.diagrams.first.children.first.id}/bounds/x",
          d1.path
        )
      end

      def test_type_query_method_helpers
        d1 = Difference.new(
          ArchimateNodeAttributeReference.new(@model, :name),
          nil
        )

        refute d1.insert?
        refute d1.delete?
        refute d1.change?
        refute d1.move?
      end
    end
  end
end
