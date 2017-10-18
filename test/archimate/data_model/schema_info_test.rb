# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class SchemaInfoTest < Minitest::Test
      def test_me
        si = SchemaInfo.new
        assert_nil si.schema
        assert_nil si.schemaversion
        assert_empty si.elements
      end
    end
  end
end
