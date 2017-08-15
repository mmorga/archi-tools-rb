# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of any XML attribute for arbitrary content like metadata
    class AnyAttribute
      include Comparison

      model_attr :attribute # Strict::String
      model_attr :prefix # Strict::String
      model_attr :value # Strict::String

      def initialize(attribute, value, prefix: "")
        @attribute = attribute
        @prefix = prefix
        @value = value
      end
    end
  end
end
