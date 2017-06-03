# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class DiffTest < Minitest::Test
      def test_it_shows_no_diffs_on_identical_files
        File.open(File.join(TEST_EXAMPLES_FOLDER, "base.archimate")) do |file1|
          File.open(File.join(TEST_EXAMPLES_FOLDER, "base.archimate")) do |file2|
            diffs = Diff.diff(file1, file2)
            assert diffs.empty?
          end
        end
      end
    end
  end
end
