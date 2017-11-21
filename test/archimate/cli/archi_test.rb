# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

module Archimate
  module Cli
    class ArchiTest < Minitest::Test
      def setup
        @archi = Archi.new
        @test_file = Tempfile.new("test.archimate")
      end

      def teardown
        @test_file.close
        @test_file.unlink
      end

      # TODO: make this actually test something
      def test_dedupe
        Archi.start(
          [
            "dedupe",
            File.join(TEST_EXAMPLES_FOLDER, 'base.archimate'),
            "-o",
            @test_file,
            "-m",
            "-f",
            "-n"
          ]
        )
      end
    end
  end
end
