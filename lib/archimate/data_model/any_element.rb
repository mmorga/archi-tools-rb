# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of any XML element for arbitrary content like metadata
    class AnyElement < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :element, Strict::String
      attribute :prefix, Strict::String.optional.default("")
      attribute :attributes, Strict::Array.member(AnyAttribute).default([])
      attribute :content, Strict::String.optional.default(nil)
      attribute :children, Strict::Array.member(AnyElement).default([])
    end
    Dry::Types.register_class(AnyElement)
  end
end
