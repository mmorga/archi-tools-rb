# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class XmlTextconvTest < Minitest::Test
      def setup
        @infile = File.join(TEST_EXAMPLES_FOLDER, "base.archimate")
        @outfile = Tempfile.new("formatted.xml")
        @xml_textconv = XmlTextconv.new(@infile, @outfile)
      end

      def teardown
        @outfile.close
        @outfile.unlink
      end

      def test_indent
        assert_equal "    ", @xml_textconv.indent(2)
      end
    end
  end
end
