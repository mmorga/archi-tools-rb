# frozen_string_literal: true

require "test_helper"
require "tempfile"

module Archimate
  class CleanTest < Minitest::Test
    def test_clean
      removed_items = Tempfile.new("removed")
      removed_items.close
      cleaned_archimate = Tempfile.new("archimate")
      cleaned_archimate.close
      out, err = capture_io do
        Cli::Archi.start [
          "clean", "-n", "-f",
          "-r", removed_items.path,
          "-o", cleaned_archimate.path,
          "test/examples/unclean.archimate"
        ]
      end
      removed_log = File.read(removed_items.path)
      assert_match "BusinessActor<296>[Front Office]", removed_log
      assert_empty err
      assert_match "Unreferenced Elements: 120\n", out
      assert_match "Unreferenced Relationships: 178\n", out
      clean_model = Archimate.read(cleaned_archimate.path)
      assert_empty clean_model.elements
      assert_empty clean_model.relationships
    ensure
      removed_items.unlink
      cleaned_archimate.unlink
    end
  end
end
