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
        doc = Nokogiri::XML.parse(result_io.string)
        written_model = ArchiFileReader.new(doc).parse

        assert_equal @model, written_model
      end

      def test_remove_nil_values
        h = {
          "z" => "something",
          "m" => nil,
          "a" => "this"
        }
        assert_equal %w(z m a), h.keys
        expected_keys = %w(z a)

        result = ArchiFileWriter.new(@model).remove_nil_values(h)

        assert_equal expected_keys, result.keys
        assert_equal expected_keys, h.keys
      end
    end
  end
end
