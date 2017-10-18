# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of any XML element for arbitrary content like metadata
    class AnyElement
      include Comparison

      # @!attribute [r] element
      #   @return [String]
      model_attr :element
      # @!attribute [r] prefix
      #   @return [String, NilClass]
      model_attr :prefix
      # @!attribute [r] attributes
      #   @return [Array<AnyAttribute>]
      model_attr :attributes
      # @!attribute [r] content
      #   @return [String, NilClass]
      model_attr :content
      # @!attribute [r] children
      #   @return [Array<AnyElement>]
      model_attr :children

      def initialize(element:, prefix: "", attributes: [], content: nil, children: [])
        @element = element
        @prefix = prefix
        @attributes = attributes
        @content = content
        @children = children
      end

      def to_sym
        element&.to_sym
      end
    end
  end
end
