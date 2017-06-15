# frozen_string_literal: true

module Archimate
  module DataModel
    class NamedReferenceable < Referenceable
      # Note: minimum 1 name is required for a Named Referenceable
      # attribute :name, Strict::Array.member(LangString).default([]) .constrained(min_size: 1)
      # attribute :documentation, DocumentationGroup
      # attribute :grp_any, Strict::Array.member(AnyGroup).default([])
    end

    Dry::Types.register_class(NamedReferenceable)
  end
end
