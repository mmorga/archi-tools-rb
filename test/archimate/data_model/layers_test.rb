# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class LayersTest < Minitest::Test
      def test_case_matching
        subject = Layers::Strategy

        case subject
        when Layers::Strategy
          pass("Matched")
        when Layers::Business
          fail "Didn't expect to match this"
        when Layers::Application
          fail "Didn't expect to match this"
        when Layers::Technology
          fail "Didn't expect to match this"
        when Layers::Physical
          fail "Didn't expect to match this"
        when Layers::Motivation
          fail "Didn't expect to match this"
        when Layers::implementation_and_migration
          fail "Didn't expect to match this"
        when Layers::Connectors
          fail "Didn't expect to match this"
        else
          fail "Unexpected Element Layer: #{subject}"
        end
      end
    end
  end
end
