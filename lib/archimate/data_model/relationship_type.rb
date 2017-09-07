# frozen_string_literal: true
require "ruby-enum"

module Archimate
  module DataModel
    RELATION_VERBS = {
      "AccessRelationship" => "accesses",
      "AggregationRelationship" => "aggregates",
      "AssignmentRelationship" => "is assigned to",
      "AssociationRelationship" => "is associated with",
      "CompositionRelationship" => "composes",
      "FlowRelationship" => "flows to",
      "InfluenceRelationship" => "influenecs",
      "RealisationRelationship" => "realizes",
      "SpecialisationRelationship" => "specializes",
      "TriggeringRelationship" => "triggers",
      "UsedByRelationship" => "is used by"
    }.freeze

    class RelationshipType
      include Ruby::Enum

      define :AccessRelationship, "AccessRelationship"
      define :AggregationRelationship, "AggregationRelationship"
      define :AssignmentRelationship, "AssignmentRelationship"
      define :AssociationRelationship, "AssociationRelationship"
      define :CompositionRelationship, "CompositionRelationship"
      define :FlowRelationship, "FlowRelationship"
      define :InfluenceRelationship, "InfluenceRelationship"
      define :RealisationRelationship, "RealisationRelationship"
      define :SpecialisationRelationship, "SpecialisationRelationship"
      define :TriggeringRelationship, "TriggeringRelationship"
      define :UsedByRelationship, "UsedByRelationship" # @todo Support: Serving
      define :GroupingRelationship, "GroupingRelationship"

      def self.===(other)
        values.include?(other)
      end
    end
  end
end
