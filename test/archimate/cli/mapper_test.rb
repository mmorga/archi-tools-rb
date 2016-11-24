# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class MapperTest < Minitest::Test
      def test_initialize
        model = build_model
        output_io = StringIO.new
        mapper = Mapper.new(model, output_io)
        assert_equal model, mapper.model
        assert_equal output_io, mapper.instance_variable_get(:@output)
      end
    end
  end
end
