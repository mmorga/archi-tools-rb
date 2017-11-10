# frozen_string_literal: true

require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ModelExchangeFileWriter30Test < Minitest::Test
      attr_accessor :model

      def setup
        @model_source = archisurance_model_exchange_30_source.gsub(" />", "/>").delete("\r")
        @model = model_exchange_archisurance_30_model
      end

      def test_write
        result_io = StringIO.new
        ModelExchangeFileWriter30.write(@model, result_io)
        assert_equal @model_source, result_io.string
      end
    end
  end
end
