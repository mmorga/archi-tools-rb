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
    class Organization < ArchimateNode # was Referenceable
      attribute :id, Identifier.optional # .constrained(format: /[[[:alpha:]]_][w-.]*/)
      attribute :name, LangString.optional # LabelGroup in the XSD, TODO: this is a LangString collection
      attribute :type, Strict::String.optional # I believe this is used only for Archi formats
      attribute :documentation, DocumentationGroup
      attribute :items, Strict::Array.member(Identifier).default([]) # TODO: Convert this to referenceable
      attribute :organizations, Strict::Array.member(Organization).default([]) # item in the XSD
      # attribute :other_elements, Strict::Array.member(AnyElement).default([])
      # attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])

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
