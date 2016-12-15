# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class MapperTest < Minitest::Test
      def test_initialize
        model = build_model
        output_io = StringIO.new
        aio = AIO.new(model: model, output_io: output_io)

        mapper = Mapper.new(aio)

        assert_equal model, mapper.model
        assert_equal output_io, mapper.instance_variable_get(:@output)
      end
    end
  end
end
