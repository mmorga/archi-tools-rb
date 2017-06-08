# frozen_string_literal: true

module Archimate
  module DataModel
    # Node type to allow a Label in a Artifact. the "label" element holds the info for the Note.
    class Label < ViewNode
      # conceptRef is a reference to an concept for this particular label, along with the attributeRef
      # which references the particular concept's part which this label represents.
      attribute :concept_ref, Identifier
      # conceptRef is a reference to an concept for this particular label, along with the partRef
      # which references the particular concept's part which this label represents. If this attribute
      # is set, then there is no need to add a label tag in the Label parent (since it is contained in the model).
      # the XPATH statement is meant to be interpreted in the context of what the conceptRef points to.
      attribute :xpath_path, Strict::String.optional
    end

    Dry::Types.register_class(Label)
  end
end
