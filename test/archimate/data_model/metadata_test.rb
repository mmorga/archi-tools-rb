# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class MetadataTest < Minitest::Test
      def test_constructor
        metadata = Metadata.new(schema_infos: ["si"])
        assert_equal ["si"], metadata.schema_infos
      end
    end
  end
end
