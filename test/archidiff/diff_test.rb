require 'test_helper'

module Archidiff
  class DiffTest < Minitest::Test
    def test_it_shows_no_diffs_on_identical_files
      File.open(File.join(File.dirname(__FILE__), "..", "examples", "base.archimate")) do |file1|
        File.open(File.join(File.dirname(__FILE__), "..", "examples", "base.archimate")) do |file2|
          diffs = Diff.diff(file1, file2)
          assert diffs.empty?
        end
      end
    end
  end
end
