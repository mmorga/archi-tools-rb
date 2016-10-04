# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class ProjectorTest < Minitest::Test
      def test_me
        projector = Projector.new
        refute_nil projector
      end
    end
  end
end
