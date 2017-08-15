# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of any XML element for arbitrary content like metadata
    class AnyElement
      include Comparison

      model_attr :element # Strict::String
      model_attr :prefix # Strict::String.optional.default("")
      model_attr :attributes # Strict::Array.member(AnyAttribute).default([])
      model_attr :content # Strict::String.optional.default(nil)
      model_attr :children # Strict::Array.member(AnyElement).default([])

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
