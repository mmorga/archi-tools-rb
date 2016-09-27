# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class MapperTest < Minitest::Test
      def test_initialize
        doc = Archimate.new_xml_doc
        output_io = StringIO.new
        mapper = Mapper.new(doc, output_io)
        assert_equal doc, mapper.instance_variable_get(:@doc)
        assert_equal output_io, mapper.instance_variable_get(:@output)
      end
    end
  end
end
