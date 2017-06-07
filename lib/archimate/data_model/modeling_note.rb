# frozen_string_literal: true

module Archimate
  module DataModel
    # This is a set of notes to the modeler on how to use and model with this viewpoint. Could contain rules
    # or constraints. The part hold the information for this element.
    class ModelingNote < ArchimateNode
      attribute :documentation, DocumentationGroup # .constrained(min_size: 1)
      # `type` attribute expresses a type for the notes, e.g. OCL for OCL rules.
      attribute :type, Strict::String.optional
    end
  end
end
