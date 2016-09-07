# frozen_string_literal: true
require 'test_helper'

module Archimate
  class OutputIOTest < Minitest::Test
    def test_defaults
      called = false
      OutputIO.new({}) do |io|
        called = true
        assert_equal $stdout, io
      end
      assert called
    end

    def test_gets_an_io_for_filename
      called = false
      filename = "test_maybe_io_file.xml"
      OutputIO.new("output" => filename) do |io|
        called = true
        assert io.is_a?(IO)
      end
      assert called
      assert File.exist?(filename)
      FileUtils.rm filename
    end
  end
end
