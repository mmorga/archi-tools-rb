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
    # @note that Organization must fit into a tree structure (so strictly nested).
    class Organization
      include Comparison

      # Format should match +/[[[:alpha:]]_][w-.]*/+ to be valid for Archimate
      # Model exchange format
      # @return [Identifier, NilClass]
      model_attr :id
      # LabelGroup in the XSD
      # @return [LangString, NilClass]
      model_attr :name
      # I believe this is used only for Archi formats
      # @return [String, NilClass]
      model_attr :type
      # @return [PreservedLangString, NilClass]
      model_attr :documentation
      # @return [Array<Object>]
      model_attr :items, writable: true
      # item in the XSD
      # @return [Array<Organization>]
      model_attr :organizations, writable: true
      # # @return [Array<AnyElement>]
      # model_attr :other_elements
      # # @return [Array<AnyAttribute>]
      # model_attr :other_attributes

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
