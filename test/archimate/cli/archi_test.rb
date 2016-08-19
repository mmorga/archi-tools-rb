require 'test_helper'
require 'pp'

module Archimate
  module Cli
    class ArchiTest < Minitest::Test
      def setup
        @archi = Archi.new
      end

      def test_map
        Archi.start(["map", File.join(TEST_EXAMPLES_FOLDER, 'base.archimate')])
        # TODO: make this actually test something
      end

      def test_merge
        Archi.start(
          [
            "merge",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            File.join(TEST_EXAMPLES_FOLDER, 'merger_1_1.archimate'),
            "-o",
            File.join(TEST_OUTPUT_FOLDER, "test_merge.archimate")
          ]
        )
        # TODO: make this actually test something
      end

      def test_svg
        Archi.start(["svg", File.join(TEST_EXAMPLES_FOLDER, 'base.archimate')])
        # TODO: make this actually test something
      end

      def test_dupes
        Archi.start(["dupes", File.join(TEST_EXAMPLES_FOLDER, 'base.archimate')])
        # TODO: make this actually test something
      end

      def test_clean
        Archi.start(
          [
            "clean",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            File.join(TEST_OUTPUT_FOLDER, "test_dedupe.archimate"),
            "-r",
            File.join(TEST_OUTPUT_FOLDER, "test_clean_removed.xml")
          ]
        )
        # TODO: make this actually test something
      end

      def test_dedupe
        Archi.start(
          [
            "dedupe",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            File.join(TEST_OUTPUT_FOLDER, "test_clean.archimate"),
            "-m",
            "-f"
          ]
        )
        # TODO: make this actually test something
      end
    end
  end
end
