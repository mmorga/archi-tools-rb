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
    class Organization
      include Comparison

      model_attr :id # Identifier.optional # .constrained(format: /[[[:alpha:]]_][w-.]*/)
      model_attr :name # LangString.optional.default(nil) # LabelGroup in the XSD
      model_attr :type # Strict::String.optional.default(nil) # I believe this is used only for Archi formats
      model_attr :documentation # PreservedLangString.optional.default(nil)
      model_attr :items # Strict::Array.member(Dry::Struct).default([])
      model_attr :organizations # Strict::Array.member(Organization).default([]) # item in the XSD
      # model_attr :other_elements # Strict::Array.member(AnyElement).default([])
      # model_attr :other_attributes # Strict::Array.member(AnyAttribute).default([])

      def initialize(id: nil, name: nil, type: nil, documentation: nil,
                     items: [], organizations: [])
        @id = id
        @name = name
        @type = type
        @documentation = documentation
        @items = items
        @organizations = organizations
      end

      def to_s
        "#{Archimate::Color.data_model('Organization')}<#{id}>[#{Archimate::Color.color(name, %i[white underline])}]"
      end

      def referenced_identified_nodes
        organizations.reduce(items) do |a, e|
          a.concat(e.referenced_identified_nodes)
        end
      end

      def remove(id)
        items.delete_if { |item| item.id == id }
      end
    end
  end
end
