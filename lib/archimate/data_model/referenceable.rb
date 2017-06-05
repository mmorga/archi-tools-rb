# frozen_string_literal: true

module Archimate
  module DataModel
    class Referenceable
      attribute :identifier, Identifier
      attribute :name, Strict::Array.member(LangStringType).default([])
      attribute :documentation, Strict::Array.member(Documentation).default([])
      attribute :grp_any, Strict::Array.member(AnyNode).default([])
      attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])
    end

    Dry::Types.register_class(Referenceable)
  end
end
