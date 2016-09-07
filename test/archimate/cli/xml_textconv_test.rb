# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class XmlTextconvTest < Minitest::Test
      def test_it_outputs_formatted_xml
        infile = File.join(TEST_EXAMPLES_FOLDER, "base.archimate")
        outfile = Tempfile.new("formatted.xml")
        begin
          XmlTextconv.new(infile, outfile)
        ensure
          outfile.close
          outfile.unlink
        end
      end
    end
  end
end
