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
        model_diffs = ModelDiff.new(model1, model2)
        assert_empty model_diffs.diffs
      end

      def test_diff_model_name
        model1 = Archimate::Model::Model.new("123", "base")
        model2 = Archimate::Model::Model.new("123", "change")
        model_diffs = ModelDiff.new(model1, model2).diffs
        assert_equal 1, model_diffs.size
        assert_equal Difference.new(:change, :name, :model, "base", "change"), model_diffs.first
      end
    end
  end
end
