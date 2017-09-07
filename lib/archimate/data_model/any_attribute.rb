# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of any XML attribute for arbitrary content like metadata
    class AnyAttribute
      include Comparison

      # @return [String]
      model_attr :attribute
      # @return [String]
      model_attr :prefix
      # @return [String]
      model_attr :value

      def initialize(attribute, value, prefix: "")
        @attribute = attribute
        @prefix = prefix
        @value = value
      end
    end
  end
end
