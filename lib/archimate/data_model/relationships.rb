# frozen_string_literal: true

module Archimate
  module DataModel
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
        NAME = "Composition"
        DESCRIPTION = "The composition relationship indicates that an element consists of one or more other concepts."
        WEIGHT = 10
        CLASSIFICATION = :structural
        VERB = "composes"
        OBJECT_VERB = "composed by"

        def initialize(args)
          super
        end
      end

      class Aggregation < Relationship
        NAME = "Aggregation"
        DESCRIPTION = "The aggregation relationship indicates that an element groups a number of other concepts. "
        WEIGHT = 9
        CLASSIFICATION = :structural
        VERB = "aggregates"
        OBJECT_VERB = "aggregated by"

        def initialize(args)
          super
        end
      end

      class Assignment < Relationship
        NAME = "Assignment"
        DESCRIPTION = "The assignment relationship expresses the allocation of responsibility, performance of behavior, or execution."
        WEIGHT = 8
        CLASSIFICATION = :structural
        VERB = "assigned to"
        OBJECT_VERB = "assigned from"

        def initialize(args)
          super
        end
      end

      class Realization < Relationship
        NAME = "Realization"
        DESCRIPTION = "The realization relationship indicates that an entity plays a critical role in the creation, achievement, sustenance, or operation of a more abstract entity."
        WEIGHT = 7
        CLASSIFICATION = :structural
        VERB = "realizes"
        OBJECT_VERB = "realized by"

        def initialize(args)
          super
        end
      end

      class Serving < Relationship
        NAME = "Serving"
        DESCRIPTION = "The serving relationship models that an element provides its functionality to another element. I.e. the element pointed to calls the other element."
        WEIGHT = 6
        CLASSIFICATION = :dependency
        VERB = "serves"
        OBJECT_VERB = "served by"

        def initialize(args)
          super
        end
      end

      class Access < Relationship
        NAME = "Access"
        DESCRIPTION = "The access relationship models the ability of behavior and active structure elements to observe or act upon passive structure elements."
        WEIGHT = 5
        CLASSIFICATION = :dependency
        VERB = "accesses"
        OBJECT_VERB = "accessed by"

        def initialize(args)
          super
        end
      end

      class Influence < Relationship
        NAME = "Influence"
        DESCRIPTION = "The influence relationship models that an element affects the implementation or achievement of some motivation element."
        WEIGHT = 4
        CLASSIFICATION = :dependency
        VERB = "influences"
        OBJECT_VERB = "influenced by"

        def initialize(args)
          super
        end
      end

      class Triggering < Relationship
        NAME = "Triggering"
        DESCRIPTION = "The triggering relationship describes a temporal or causal relationship between elements."
        WEIGHT = 3
        CLASSIFICATION = :dynamic
        VERB = "triggers"
        OBJECT_VERB = "triggered by"

        def initialize(args)
          super
        end
      end

      class Flow < Relationship
        NAME = "Flow"
        DESCRIPTION = "The flow relationship represents transfer from one element to another."
        WEIGHT = 2
        CLASSIFICATION = :dynamic
        VERB = "flows to"
        OBJECT_VERB = "flows from"

        def initialize(args)
          super
        end
      end

      class Specialization < Relationship
        NAME = "Specialization"
        DESCRIPTION = "The specialization relationship indicates that an element is a particular kind of another element."
        WEIGHT = 1
        CLASSIFICATION = :other
        VERB = "specializes"
        OBJECT_VERB = "specialized by"

        def initialize(args)
          super
        end
      end

      class Association < Relationship
        NAME = "Association"
        DESCRIPTION = "An association relationship models an unspecified relationship, or one that is not represented by another ArchiMate relationship."
        WEIGHT = 0
        CLASSIFICATION = :other
        VERB = "associated with"
        OBJECT_VERB = "associated from"

        def initialize(args)
          super
        end
      end

      # Junction is a relationship connector
      # *  All relationships connected with relationship connectors must be of the same type
      class AndJunction < Relationship
        NAME = "AndJunction"
        DESCRIPTION = "A junction is used to connect relationships of the same type."
        WEIGHT = 0
        CLASSIFICATION = :other
        VERB = "and junction to"
        OBJECT_VERB = "and junction from"

        def initialize(args)
          super
        end
      end

      # Junction is a relationship connector
      # *  All relationships connected with relationship connectors must be of the same type
      class OrJunction < Relationship
        NAME = "OrJunction"
        DESCRIPTION = "A junction is used to connect relationships of the same type."
        WEIGHT = 0
        CLASSIFICATION = :other
        VERB = "or junction to"
        OBJECT_VERB = "or junction from"

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

      def self.default
        [
          Relationships::Access,
          Relationships::Aggregation,
          Relationships::Assignment,
          Relationships::Association,
          Relationships::Composition,
          Relationships::Flow,
          Relationships::Realization,
          Relationships::Specialization,
          Relationships::Triggering,
          Relationships::Serving
        ].freeze
      end
    end
  end
end
