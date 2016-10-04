# frozen_string_literal: true
require 'test_helper'

module Archimate
  class DocumentTest < Minitest::Test
    BASE = File.join(TEST_EXAMPLES_FOLDER, "base.archimate")

    def test_new
      output_io = StringIO.new
      refute_nil Document.new(BASE, output_io: output_io)
    end
  end
end
