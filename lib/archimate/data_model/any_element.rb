# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of any XML element for arbitrary content like metadata
    class AnyElement < ArchimateNode
      attribute :element, Strict::String
      attribute :prefix, Strict::String.optional
      attribute :attributes, Strict::Array.member(AnyAttribute).default([])
      attribute :content, Strict::String.optional
      attribute :children, Strict::Array.member(AnyElement).default([])
    end
    Dry::Types.register_class(AnyElement)
  end
end
