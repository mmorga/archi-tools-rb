# frozen_string_literal: true

module Archimate
  module DataModel
    class NamedReferenceable < Referenceable
      attribute :name, Strict::Array.member(NameGroup).constrained(min_size: 1)
      attribute :documentation, Strict::Array.member(DocumentationGroup).default([])
      attribute :grp_any, Strict::Array.member(AnyGroup).default([])
    end

    Dry::Types.register_class(NamedReferenceable)
  end
end
