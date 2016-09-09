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
        element_list = build_list(:element, 3)
        element_hash = element_list.each_with_object({}) { |i, a| a[i.identifier] = i }
        model1 = Archimate::Model::Model.new("123", "base") do |m|
          m.elements = element_hash
        end
        model2 = Archimate::Model::Model.new("123", "base") do |m|
          m.elements = element_hash
        end
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_empty(model_diffs)
      end

      def test_diff_model_elements_insert
        element_list = build_list(:element, 3)
        element_hash = element_list.each_with_object({}) { |i, a| a[i.identifier] = i }
        model1 = Archimate::Model::Model.new("123", "base") do |m|
          m.elements = element_hash.dup
        end
        ins_el = build(:element)
        element_hash[ins_el.identifier] = ins_el
        model2 = Archimate::Model::Model.new("123", "base") do |m|
          m.elements = element_hash
        end
        model_diffs = Context.new(model1, model2).diffs(ModelDiff.new)
        assert_equal(
          [
            Difference.insert("Model<123>/elements/#{ins_el.identifier}", ins_el)
          ], model_diffs
        )
      end
    end
  end
end
