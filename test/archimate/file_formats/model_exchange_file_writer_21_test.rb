# frozen_string_literal: true

require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ModelExchangeFileWriter21Test < Minitest::Test
      attr_accessor :model

      def setup
        @model_source = archisurance_model_exchange_source.gsub(" />", "/>")
        @model = model_exchange_archisurance_model
      end

      def test_write
        result_io = StringIO.new

        assert_equal 2, model.properties.size

        ModelExchangeFileWriter21.write(@model, result_io)

        assert_equal @model_source, result_io.string
      end
    end
  end
end
