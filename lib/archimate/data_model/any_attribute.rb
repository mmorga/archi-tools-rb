# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of any XML attribute for arbitrary content like metadata
    class AnyAttribute
      include Comparison

      # @!attribute [r] attribute
      #   @return [String]
      model_attr :attribute
      # @!attribute [r] prefix
      #   @return [String]
      model_attr :prefix
      # @!attribute [r] value
      #   @return [String]
      model_attr :value

      def initialize(attribute, value, prefix: "")
        @attribute = attribute
        @prefix = prefix
        @value = value
      end
    end
  end
end
