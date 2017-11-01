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
