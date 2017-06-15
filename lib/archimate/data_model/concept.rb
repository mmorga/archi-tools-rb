# frozen_string_literal: true

module Archimate
  module DataModel
    # This is an abstract class for Concepts (Elements, Relationships, Composites, and RelationConnectors).
    class Concept < Referenceable
      attribute :properties, PropertiesList
      # group -> ConceptGroup # Empty. Available for Extension purposes.
      # attributeGroup -> ConceptAttributeGroup # Empty. Available for Extension purposes.
    end

    Dry::Types.register_class(Concept)
  end
end
