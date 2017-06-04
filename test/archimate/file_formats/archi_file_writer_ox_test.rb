# frozen_string_literal: true
require 'test_helper'
require 'test_examples'
require 'archimate/file_formats/archi_file_writer_ox'

module Archimate
  module FileFormats
    class ArchiFileWriterOxTest < Minitest::Test
      attr_accessor :model

      def setup
        @model_source = ARCHISURANCE_SOURCE
        @model = ARCHISURANCE_MODEL
      end

      def test_write
        result_io = StringIO.new

        starttime = Time.now
        ArchiFileWriterOx.write(@model, result_io)
        endtime = Time.now
        assert 0.025 > endtime.to_f - starttime.to_f, "Ox writer took: #{endtime.to_f - starttime.to_f} seconds"

        assert_equal @model_source, result_io.string
      end

      def test_remove_nil_values
        h = {
          "z" => "something",
          "m" => nil,
          "a" => "this"
        }
        assert_equal %w(z m a), h.keys
        expected_keys = %w(z a)

        result = ArchiFileWriterOx.new(@model).remove_nil_values(h)

        assert_equal expected_keys, result.keys
        assert_equal expected_keys, h.keys
      end
    end
  end
end
