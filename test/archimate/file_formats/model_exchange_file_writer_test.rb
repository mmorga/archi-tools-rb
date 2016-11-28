# frozen_string_literal: true
require 'test_helper'

module Archimate
  module FileFormats
    class ModelExchangeFileWriterTest < Minitest::Test
      attr_accessor :model

      def setup
        @model_source = ARCHISURANCE_MODEL_EXCHANGE_SOURCE.gsub(" />", "/>")
        @model = MODEL_EXCHANGE_ARCHISURANCE_MODEL
      end

      def test_write
        result_io = StringIO.new

        assert_equal 2, model.properties.size

        ModelExchangeFileWriter.write(@model, result_io)

        assert_equal @model_source, result_io.string
      end
    end
  end
end
