# frozen_string_literal: true
module Archimate
  module DataModel
    # An organization element represents a structural node in a particular organization of the model concepts.
    # An organization element may be a parent or sibling of other organization elements,
    # each one representing a unique structural node.
    #
    # An organization element may reference an ArchiMate element, ArchiMate relationship,
    # or nothing (in which case it is a structural container)
    #
    # An organization has no meaning unless it has at least child organization element.
    #
    # Note that Organization must fit into a tree structure (so strictly nested).
    class Organization < Referenceable
      attribute :items, Strict::Array.member(Strict::String).default([])
      attribute :organizations, Strict::Array.member(Organization).default([])
      #       attribute :label, Strict::Array.members(LangString).constrained(:min_size = 1)
      #       attribute :documentation, Strict::Array.members(PreservedLangString).default([])
      #       attribute :item, Strict::Array.members(Organization).default([])
      #       attribute :other, Strict::Array.default([])
      #       attribute :identifier, Strict::String.constrained(format: /[[[:alpha:]]_][w-.]*/).optional
      #       attribute :identifierRef, Strict::String.constrained(format: /[[[:alpha:]]_][w-.]*/).optional
      #       attribute :other, Strict::Array.default([])
      attribute :properties, PropertiesList # Note: this is not in the model under element
      # it's added under Real Element

      def to_s
        "#{Archimate::Color.data_model('Organization')}<#{id}>[#{Archimate::Color.color(name, [:white, :underline])}]"
      end

      def referenced_identified_nodes
        organizations.reduce(items) do |a, e|
          a.concat(e.referenced_identified_nodes)
        end
      end

      def remove(id)
        items.delete(id)
      end
    end
    Dry::Types.register_class(Organization)
  end
end
