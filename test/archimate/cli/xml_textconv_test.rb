# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class XmlTextconvTest < Minitest::Test
      def test_it_outputs_formatted_xml
        formatted_xml = File.join(TEST_OUTPUT_FOLDER, "formatted.xml")
        FileUtils.rm(formatted_xml) if File.exist?(formatted_xml)
        file1 = File.join(TEST_EXAMPLES_FOLDER, "base.archimate")
        file2 = File.join(formatted_xml)
        XmlTextconv.new(file1, file2)
      end
    end
  end
end
