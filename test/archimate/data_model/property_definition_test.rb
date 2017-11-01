# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class PropertyDefinitionTest < Minitest::Test
      def test_hash_for_key
        cases = %w[one apple frank]
        hashes = cases.map { |key| PropertyDefinition.identifier_for_key(key) }
        assert_equal hashes.size, hashes.uniq.size
        assert(hashes.all? { |hash| hash.instance_of?(String) })
      end

      def test_constructor
        name = LangString.new("owner")
        subject = DataModel::PropertyDefinition.new(
          id: "id-123",
          name: name,
          documentation: nil,
          type: "string"
        )

        refute_nil subject
      end

      def test_factory
        subject = build_property_definition
        assert_kind_of PropertyDefinition, subject
        refute_empty subject.id
        refute_empty subject.name
        assert_nil subject.documentation
        assert_equal "string", subject.type
      end
    end
  end
end
