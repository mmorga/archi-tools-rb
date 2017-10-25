# frozen_string_literal: true

module Archimate
  module DataModel
    ACCESS_TYPE = %w[Access Read Write ReadWrite].freeze
    AccessTypeEnum = String #String.enum(*ACCESS_TYPE)

    # A base relationship type that can be extended by concrete ArchiMate types.
    #
    # Note that RelationshipType is abstract, so one must have derived types of this type. this is indicated in xml
    # by having a tag name of "relationship" and an attribute of xsi:type="AccessRelationship" where AccessRelationship is
    # a derived type from RelationshipType.
    class Relationship
      # @todo: this should be removed once concrete Relationships are used.
      # @deprecated
      WEIGHTS = {
        'GroupingRelationship' => 0,
        'JunctionRelationship' => 0,
        'AssociationRelationship' => 0,
        'SpecialisationRelationship' => 1,
        'FlowRelationship' => 2,
        'TriggeringRelationship' => 3,
        'InfluenceRelationship' => 4,
        'AccessRelationship' => 5,
        'ServingRelationship' => 6,
        'UsedByRelationship' => 6,
        'RealizationRelationship' => 7,
        'RealisationRelationship' => 7,
        'AssignmentRelationship' => 8,
        'AggregationRelationship' => 9,
        'CompositionRelationship' => 10
      }

      include Comparison

      # @!attribute [r] id
      #   @return [String]
      model_attr :id
      # @!attribute [r] name
      #   @return [LangString, NilClass]
      model_attr :name
      # @!attribute [r] documentation
      #   @return [PreservedLangString, NilClass]
      model_attr :documentation
      # # @return [Array<AnyElement>]
      # model_attr :other_elements
      # # @return [Array<AnyAttribute>]
      # model_attr :other_attributes
      # @note type here was used for the Element/Relationship/Diagram type
      # @!attribute [r] type
      #   @return [String, NilClass]
      model_attr :type
      # @!attribute [r] properties
      #   @return [Array<Property>]
      model_attr :properties
      # @todo is this optional?
      # @!attribute [rw] source
      #   @return [Element, Relationship]
      model_attr :source, comparison_attr: :id, writable: true
      # @todo is this optional?
      # @!attribute [rw] target
      #   @return [Element, Relationship]
      model_attr :target, comparison_attr: :id, writable: true
      # @!attribute [r] access_type
      #   @return [AccessTypeEnum, NilClass]
      model_attr :access_type
      # @!attribute [r] derived
      #   @return [Boolean] this is a derived relation if true
      model_attr :derived

      def initialize(id:, name: nil, documentation: nil, type: nil,
                     properties: [], source:, target:, access_type: nil,
                     derived: false)
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @properties = properties
        @source = source
        @target = target
        @access_type = access_type
        @derived = derived
      end

      def replace(entity, with_entity)
        @source = with_entity.id if source == entity.id
        @target = with_entity.id if target == entity.id
      end

      def to_s
        Archimate::Color.color(
          "#{Archimate::Color.data_model(type)}<#{id}>[#{Archimate::Color.color(name&.strip || '', %i[black underline])}]",
          :on_light_magenta
        ) + " #{source} -> #{target}"
      end

      def description
        [
          name.nil? ? nil : "#{name}:",
          RELATION_VERBS.fetch(type, nil)
        ].compact.join(" ")
      end

      # @todo remove when it doesn't break diff merge conflicts
      # @deprecated
      def referenced_identified_nodes
        [@source, @target].compact
      end

      # Diagrams that this element is referenced in.
      def diagrams
        @diagrams ||= in_model.diagrams.select do |diagram|
          diagram.relationship_ids.include?(id)
        end
      end

      # Copy any attributes/docs, etc. from each of the others into the original.
      #     1. Child `label`s with different `xml:lang` attribute values
      #     2. Child `documentation` (and different `xml:lang` attribute values)
      #     3. Child `properties`
      #     4. Any other elements
      # source and target don't change on a merge
      def merge(relationship)
        super
        access_type ||= relationship.access_type
      end

      def weight
        WEIGHTS.fetch(type, 0)
      end
    end

    # Relationship Classifications: Structural, Dynamic, Dependency, Other
    # •  No relationships are allowed between two relationships
    # •  All relationships connected with relationship connectors must be of
    #    the same type
    # •  A chain of relationships of the same type that connects two elements,
    #    and is in turn connected via relationship connectors, is valid only if
    #    a direct relationship of that same type between those two elements is
    #    valid
    # •  A relationship connecting an element with a second relationship can
    #    only be an aggregation, composition, or association; aggregation or
    #    composition are valid only from a composite element to that second
    #    relationship
    #
    # Aggregation, composition, and specialization relationships are always
    # permitted between two elements of the same type, and association is
    # always allowed between any two elements, and between any element and
    # relationship.

    class Composition < Relationship
      CLASSIFICATION = :structural
      WEIGHT = 10
    end

    class Aggregation < Relationship
      CLASSIFICATION = :structural
      WEIGHT = 9
    end

    class Assignment < Relationship
      CLASSIFICATION = :structural
      WEIGHT = 8
    end

    class Realization < Relationship
      CLASSIFICATION = :structural
      WEIGHT = 7
    end

    class Serving < Relationship
      CLASSIFICATION = :dependency
      WEIGHT = 6
    end

    class Access < Relationship
      CLASSIFICATION = :dependency
      WEIGHT = 5
    end

    class Influence < Relationship
      CLASSIFICATION = :dependency
      WEIGHT = 4
    end

    class Triggering < Relationship
      CLASSIFICATION = :dynamic
      WEIGHT = 3
    end

    class Flow < Relationship
      CLASSIFICATION = :dynamic
      WEIGHT = 2
    end

    class Specialization < Relationship
      CLASSIFICATION = :other
      WEIGHT = 1
    end

    class Association < Relationship
      CLASSIFICATION = :other
      WEIGHT = 0
    end

    # Junction is a relationship connector
    # •  All relationships connected with relationship connectors must be of the same type
    class Junction < Relationship
      CLASSIFICATION = :other
      WEIGHT = 0
    end
  end
end
