# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class DuperTest < Minitest::Test
      def setup
        output_io = StringIO.new
        @duper = Duper.new(build_model, output_io)
      end

      def test_new
        refute_nil @duper
      end
    end
  end
end
