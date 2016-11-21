# frozen_string_literal: true
require 'test_helper'

module Archimate
  class ArchiFileWriterTest < Minitest::Test
    attr_accessor :model

    def setup
      @model_source = File.read(File.join(TEST_EXAMPLES_FOLDER, "archisurance.archimate"))
      @model = ArchiFileReader.parse(@model_source)
    end

    def test_write
      result_io = StringIO.new

      ArchiFileWriter.write(@model, result_io)

      assert_equal @model_source, result_io.string
    end

    def test_remove_nil_values
      h = {
        "z" => "something",
        "m" => nil,
        "a" => "this"
      }
      assert_equal %w(z m a), h.keys
      expected_keys = ["z", "a"]

      result = ArchiFileWriter.new(@model).remove_nil_values(h)

      assert_equal expected_keys, result.keys
      assert_equal expected_keys, h.keys
    end
  end
end
