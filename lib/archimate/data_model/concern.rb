# frozen_string_literal: true

module Archimate
  module DataModel
    # document attribute holds all the concern information.
    #
    # This is ConcernType in the XSD
    class Concern
      include Comparison

      # @!attribute [r] label
      #   @return [LangString] one label is required
      model_attr :label
      # @!attribute [r] documentation
      #   @return [PreservedLangString]
      model_attr :documentation
      # @!attribute [r] stakeholders
      #   @return [Array<LangString>]
      model_attr :stakeholders

      def initialize(label:, documentation: nil, stakeholders: [])
        raise "label is required" unless label
        raise "stakeholders is a list" unless stakeholders.is_a?(Array)
        @label = label
        @documentation = documentation
        @stakeholders = stakeholders
      end
    end
  end
end
