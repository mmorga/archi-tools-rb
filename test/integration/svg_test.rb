# frozen_string_literal: true

require 'test_helper'
require 'test_examples'

module Archimate
  class SvgTest < Minitest::Test
    def test_svg_archi_format
      Dir.mktmpdir do |dir|
        _out, _err = capture_io do
          Cli::Archi.start ["svg", "-n", "-o", dir, "test/examples/archisurance.archimate"]
        end
        svgs = Dir.glob(File.join(dir, "*.svg"))
        expected_ids = archisurance_model.diagrams.map(&:id).sort
        actual_ids = svgs.map { |name| File.basename(name, ".svg") }.sort
        assert_equal expected_ids, actual_ids
      end
    end

    def test_svg_all_elements_and_relationships
      model = Archimate.read("test/examples/everything.archimate")
      Dir.mktmpdir do |dir|
        out, err = capture_io do
          Cli::Archi.start ["svg", "-n", "-o", dir, "test/examples/everything.archimate"]
        end
        assert_empty out
        assert_empty err
        svgs = Dir.glob(File.join(dir, "*.svg"))
        expected_ids = model.diagrams.map(&:id).sort
        actual_ids = svgs.map { |name| File.basename(name, ".svg") }.sort
        assert_equal expected_ids, actual_ids
      end
    end
  end
end
