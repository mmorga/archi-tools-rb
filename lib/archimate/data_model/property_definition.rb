# frozen_string_literal: true

module Archimate
  module DataModel
    # An enumeration of data types.
    # @todo consider making this an enumeration
    PROPERTY_DEFINITION_TYPES = %w[string boolean currency date time number].freeze

    # A Property definition type containing its unique identifier, name, and data type.
    class PropertyDefinition
      include Comparison

      # @!attribute [r] id
      #   @return [String]
      model_attr :id
      # @!attribute [r] name
      #   @return [LangString]
      model_attr :name
      # @!attribute [r] documentation
      #   @return [PreservedLangString, NilClass]
      model_attr :documentation
      # # @!attribute [r] other_elements
      #   @return [Array<AnyElement>]
      model_attr :other_elements
      # # @!attribute [r] other_attributes
      #   @return [Array<AnyAttribute>]
      model_attr :other_attributes
      # @!attribute [r] type
      #   @note if +type+ is nil, then type "string" is assumed
      #   @see Archimate::DataModel::PROPERTY_DEFINITION_TYPES
      #   @return [String, NilClass]
      model_attr :type

      def self.identifier_for_key(key)
        (self.class.hash ^ key.hash).to_s(16)
      end

      def initialize(id:, name:, documentation: nil, type: nil)
        @id = id
        @name = name
        @documentation = documentation
        @type = type
      end
    end
  end
end
