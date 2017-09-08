# frozen_string_literal: true

module Archimate
  module DataModel
    # This is a set of notes to the modeler on how to use and model with this viewpoint. Could contain rules
    # or constraints. The part hold the information for this element.
    class ModelingNote
      include Comparison

      # @!attribute [r] documentation
      #   @return [PreservedLangString]
      model_attr :documentation
      # `type` attribute expresses a type for the notes, e.g. OCL for OCL rules.
      # @!attribute [r] type
      #   @return [String, NilClass]
      model_attr :type

      def initialize(documentation:, type: nil)
        @documentation = documentation
        @type = type
      end
    end
  end
end
