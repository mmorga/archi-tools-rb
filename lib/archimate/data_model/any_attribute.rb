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
      model_attr :prefix, default: ""
      # @!attribute [r] value
      #   @return [String]
      model_attr :value
    end
  end
end
