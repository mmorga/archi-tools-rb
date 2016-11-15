# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class SvgerTest < Minitest::Test
      def test_me
        model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        aio = AIO.new
        svger = Svger.new(model, aio)
        refute_nil svger
      end
    end
  end
end
