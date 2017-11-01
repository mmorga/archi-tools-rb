# frozen_string_literal: true

module Archimate
  module DataModel
    ACCESS_TYPE = %w[Access Read Write ReadWrite].freeze
    AccessTypeEnum = String # String.enum(*ACCESS_TYPE)

    # A base relationship type that can be extended by concrete ArchiMate types.
    #
    # Note that RelationshipType is abstract, so one must have derived types of
    # this type. this is indicated in xml by having a tag name of "relationship"
    # and an attribute of xsi:type="AccessRelationship" where AccessRelationship
    # is a derived type from RelationshipType.
    class Relationship
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
      # @return [Array<AnyElement>]
      # model_attr :other_elements
      # @return [Array<AnyAttribute>]
      # model_attr :other_attributes
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

      def initialize(id:, name: nil, documentation: nil,
                     properties: [], source:, target:, access_type: nil,
                     derived: false)
        @id = id
        @name = name
        @documentation = documentation
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

      def type
        self.class.name.split("::").last
      end

      def weight
        self.class::WEIGHT
      end

      def classification
        self.class::CLASSIFICATION
      end

      def verb
        self.class::VERB
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
          verb
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
        @access_type ||= relationship.access_type
      end
    end

    # Relationship Classifications: Structural, Dynamic, Dependency, Other
    # *  No relationships are allowed between two relationships
    # *  All relationships connected with relationship connectors must be of
    #    the same type
    # *  A chain of relationships of the same type that connects two elements,
    #    and is in turn connected via relationship connectors, is valid only if
    #    a direct relationship of that same type between those two elements is
    #    valid
    # *  A relationship connecting an element with a second relationship can
    #    only be an aggregation, composition, or association; aggregation or
    #    composition are valid only from a composite element to that second
    #    relationship
    #
    # Aggregation, composition, and specialization relationships are always
    # permitted between two elements of the same type, and association is
    # always allowed between any two elements, and between any element and
    # relationship.
    module Relationships
      class Composition < Relationship
        WEIGHT = 10
        CLASSIFICATION = :structural
        VERB = "composes"

        def initialize(args)
          super
        end
      end

      class Aggregation < Relationship
        WEIGHT = 9
        CLASSIFICATION = :structural
        VERB = "aggregates"

        def initialize(args)
          super
        end
      end

      class Assignment < Relationship
        WEIGHT = 8
        CLASSIFICATION = :structural
        VERB = "assigned to"

        def initialize(args)
          super
        end
      end

      class Realization < Relationship
        WEIGHT = 7
        CLASSIFICATION = :structural
        VERB = "realizes"

        def initialize(args)
          super
        end
      end

      class Serving < Relationship
        WEIGHT = 6
        CLASSIFICATION = :dependency
        VERB = "serves"

        def initialize(args)
          super
        end
      end

      class Access < Relationship
        WEIGHT = 5
        CLASSIFICATION = :dependency
        VERB = "accesses"

        def initialize(args)
          super
        end
      end

      class Influence < Relationship
        WEIGHT = 4
        CLASSIFICATION = :dependency
        VERB = "influences"

        def initialize(args)
          super
        end
      end

      class Triggering < Relationship
        WEIGHT = 3
        CLASSIFICATION = :dynamic
        VERB = "triggers"

        def initialize(args)
          super
        end
      end

      class Flow < Relationship
        WEIGHT = 2
        CLASSIFICATION = :dynamic
        VERB = "flows to"

        def initialize(args)
          super
        end
      end

      class Specialization < Relationship
        WEIGHT = 1
        CLASSIFICATION = :other
        VERB = "specializes"

        def initialize(args)
          super
        end
      end

      class Association < Relationship
        WEIGHT = 0
        CLASSIFICATION = :other
        VERB = "is associated with"

        def initialize(args)
          super
        end
      end

      # Junction is a relationship connector
      # *  All relationships connected with relationship connectors must be of the same type
      class Junction < Relationship
        WEIGHT = 0
        CLASSIFICATION = :other
        VERB = "junction to"

        def initialize(args)
          super
        end
      end

      # Junction is a relationship connector
      # *  All relationships connected with relationship connectors must be of the same type
      class AndJunction < Relationship
        WEIGHT = 0
        CLASSIFICATION = :other
        VERB = "junction to"

        def initialize(args)
          super
        end
      end

      # Junction is a relationship connector
      # *  All relationships connected with relationship connectors must be of the same type
      class OrJunction < Relationship
        WEIGHT = 0
        CLASSIFICATION = :other
        VERB = "junction to"

        def initialize(args)
          super
        end
      end

      def self.create(*args)
        # type = args[0].delete(:type)
        # cls_name = type.strip.sub(/Relationship$/, '')
        # cls_name = RELATIONSHIP_SUBSTITUTIONS.fetch(cls_name, cls_name)
        cls_name = str_filter(args[0].delete(:type))
        Relationships.const_get(cls_name).new(*args)
      rescue NameError => err
        Archimate::Logging.error "An invalid relationship type '#{cls_name}' was used to create a Relationship"
        raise err
      end

      def self.===(other)
        constants.map(&:to_s).include?(str_filter(other))
      end

      def self.str_filter(str)
        relationship_substitutions = {
          "Realisation" => "Realization",
          "Specialisation" => "Specialization",
          "UsedBy" => "Serving"
        }.freeze

        cls_name = str.strip.sub(/Relationship$/, '')
        relationship_substitutions.fetch(cls_name, cls_name)
      end

      def self.classes
        constants.map { |cls_name| const_get(cls_name) }
      end
    end
  end
end
