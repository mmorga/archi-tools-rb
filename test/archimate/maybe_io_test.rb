# frozen_string_literal: true
require 'test_helper'

module Archimate
  class MaybeIOTest < Minitest::Test
    def test_gets_a_nil_io_for_nil_input
      called = false
      MaybeIO.new(nil) do |io|
        called = true
        assert io.respond_to?(:write)
      end
      assert called
    end

    def test_gets_an_io_for_filename
      called = false
      filename = "test_maybe_io_file.xml"
      MaybeIO.new(filename) do |io|
        called = true
        assert io.is_a?(IO)
      end
      assert called
      assert File.exist?(filename)
      FileUtils.rm filename
    end
  end
end
