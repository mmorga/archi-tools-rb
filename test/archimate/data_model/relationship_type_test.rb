# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class RelationshipTypeTest < Minitest::Test
      def test_case_matching
        RelationshipType.values.each do |relationship_type|
          case relationship_type
          when RelationshipType
            pass "#{relationship_type} was a RelationshipType"
          else
            fail "#{relationship_type} was not a RelationshipType"
          end
        end
      end

      def test_case_matching_negatives
        %w[ArchimateDiagramModel SketchModel].each do |str|
          case str
          when RelationshipType
            fail "#{str} should not match as a RelationshipType"
          else
            pass "This is fine"
          end
        end
      end
    end
  end
end
