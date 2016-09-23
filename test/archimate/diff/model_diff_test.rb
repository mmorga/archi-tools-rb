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
        model1 = Archimate::Model::Model.create(id: "123", name: "base")
        model2 = Archimate::Model::Model.create(id: "123", name: "change")
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal [Difference.change("Model<123>/name", "base", "change")], model_diffs
      end

      def test_diff_model_id
        model1 = Archimate::Model::Model.create(id: "123", name: "base")
        model2 = Archimate::Model::Model.create(id: "321", name: "base")
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal [Difference.change("Model<123>/id", "123", "321")], model_diffs
      end

      def test_diff_model_documentation
        model1 = Archimate::Model::Model.create(id: "123", name: "base", documentation: %w(documentation1))
        model2 = Archimate::Model::Model.create(id: "123", name: "base", documentation: %w(documentation2))
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
        elements = model1.elements.dup
        ins_el = build_element
        elements[ins_el.id] = ins_el
        model2 = model1.with(elements: elements)
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal(
          [
            Difference.insert("Model<#{model1.id}>/elements/#{ins_el.id}", ins_el)
          ], model_diffs
        )
      end

      def test_diff_model_element_changes
        element1 = build_element
        model1 = build_model(elements: Archimate.array_to_id_hash([element1]))
        from_label = element1.label
        element2 = element1.with(label: from_label + "-modified")
        model2 = model1.with(elements: Archimate.array_to_id_hash([element2]))
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal(
          [
            Difference.change("Model<#{model1.id}>/elements/#{element1.id}/label", from_label, element2.label)
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
