# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class PropertyDefinitionTest < Minitest::Test
      def test_hash_for_key
        cases = %w[one apple frank]
        hashes = cases.map { |key| PropertyDefinition.identifier_for_key(key) }
        assert_equal hashes.size, hashes.uniq.size
        assert hashes.all? { |hash| hash.instance_of?(String) }
      end
    end
  end
end
