# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class DuperTest < Minitest::Test
      def test_new
        input_doc = Archimate::new_xml_doc
        output_io = StringIO.new
        duper = Duper.new(input_doc, output_io)
      end
    end
  end
end
