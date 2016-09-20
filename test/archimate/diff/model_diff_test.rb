# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ModelDiffTest < Minitest::Test
      BASE = File.join(TEST_EXAMPLES_FOLDER, "base.archimate")
      DIFF1 = File.join(TEST_EXAMPLES_FOLDER, "diff1.archimate")

      def test_equivalent
        model1 = Archimate::ArchiFileReader.read(BASE)
        model2 = Archimate::ArchiFileReader.read(BASE)
        ctx = Context.new(model1, model2)
        model_diffs = ModelDiff.new.diffs(ctx)
        assert_empty model_diffs
      end

      def test_diff_model_name
        model1 = Archimate::Model::Model.new("123", "base")
        model2 = Archimate::Model::Model.new("123", "change")
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal [Difference.change("Model<123>/name", "base", "change")], model_diffs
      end

      def test_diff_model_id
        model1 = Archimate::Model::Model.new("123", "base")
        model2 = Archimate::Model::Model.new("321", "base")
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal [Difference.change("Model<123>/id", "123", "321")], model_diffs
      end

      def test_diff_model_documentation
        model1 = Archimate::Model::Model.new("123", "base") do |m|
          m.documentation = %w(documentation1)
        end
        model2 = Archimate::Model::Model.new("123", "base") do |m|
          m.documentation = %w(documentation2)
        end
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal(
          [
            Difference.delete("Model<123>/documentation/[0]", "documentation1"),
            Difference.insert("Model<123>/documentation/[0]", "documentation2")
          ], model_diffs
        )
      end

      def test_diff_model_elements_same
        model1 = build_model
        model2 = model1.dup
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_empty(model_diffs)
      end

      def test_diff_model_elements_insert
        model1 = build_model(with_elements: 3)
        model2 = model1.dup
        ins_el = build_element
        model2.add_element(ins_el)
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal(
          [
            Difference.insert("Model<#{model1.id}>/elements/#{ins_el.id}", ins_el)
          ], model_diffs
        )
      end

      def test_diff_model_element_changes
        element = build_element
        model1 = build_model(elements: Archimate.array_to_id_hash([element.dup]))
        from_label = element.label
        element.label += "-modified"
        model2 = model1.dup
        model2.elements = Archimate.array_to_id_hash([element])
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal(
          [
            Difference.change("Model<#{model1.id}>/elements/#{element.id}/label", from_label, element.label)
          ], model_diffs
        )
      end

      # Diagram Test Cases
      # 1. Added Diagram
      # 2. Deleted Diagram
      # 3. Changed Diagram
      def xtest_diagram_added
      end
    end
  end
end
