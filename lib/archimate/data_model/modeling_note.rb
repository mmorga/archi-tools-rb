# frozen_string_literal: true

module Archimate
  module DataModel
    # This is a set of notes to the modeler on how to use and model with this viewpoint. Could contain rules
    # or constraints. The part hold the information for this element.
    class ModelingNote < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :documentation, PreservedLangString # .constrained(min_size: 1)
      # `type` attribute expresses a type for the notes, e.g. OCL for OCL rules.
      attribute :type, Strict::String.optional
    end
  end
end
