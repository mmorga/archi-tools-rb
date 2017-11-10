# frozen_string_literal: true

module Archimate
  module DataModel
    # RelationshipReferences provides a means to allow a class that is referenced
    # by Relationship objects to get the set of:
    # * All relationships
    # * All relationships by:
    #   - a particular type
    #   - if this object is the source of target of the relationship
    module RelationshipReferences
      def relationships
        references.select { |ref| ref.is_a?(DataModel::Relationship) }
      end

      def self.included(_base)
        Relationships.classes.each do |rel_cls|
          define_method(rel_cls::VERB.tr(' ', '_').to_sym) do
            references.select { |ref| ref.is_a?(rel_cls) && ref.source == self }
          end

          define_method(rel_cls::OBJECT_VERB.tr(' ', '_').to_sym) do
            references.select { |ref| ref.is_a?(rel_cls) && ref.target == self }
          end
        end
      end
    end
  end
end
