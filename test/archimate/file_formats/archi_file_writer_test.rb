# frozen_string_literal: true

require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ArchiFileWriterTest < Minitest::Test
      attr_accessor :model

      def setup
        @model_source = archisurance_source
        @model = archisurance_model
      end

      def test_write
        result_io = StringIO.new

        ArchiFileWriter.write(@model, result_io)
        written_model = ArchiFileReader.new(result_io.string).parse
        # Archi tends to vary in expected values by 1. This patch to location
        # makes Locations still equal so long as x & y are up to 1 different than
        # the compared Location.
        DataModel::Location.send(:define_method, :==, proc do |other|
          (x - other.x).abs <= 1 &&
            (y - other.y).abs <= 1
        end)
        assert_equal model, written_model
        DataModel::Location.send(:remove_method, :==)
      end
    end
  end
end
