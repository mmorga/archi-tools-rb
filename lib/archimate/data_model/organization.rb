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
      include Referenceable

      # Format should match +/[[[:alpha:]]_][w-.]*/+ to be valid for Archimate
      # Model exchange format
      # @!attribute [r] id
      # @return [String, NilClass]
      model_attr :id, default: nil
      # LabelGroup in the XSD
      # @!attribute [r] name
      # @return [LangString, NilClass]
      model_attr :name, default: nil
      # I believe this is used only for Archi formats
      # @!attribute [r] type
      # @return [String, NilClass]
      model_attr :type, default: nil
      # @!attribute [r] documentation
      # @return [PreservedLangString, NilClass]
      model_attr :documentation, default: nil
      # @!attribute [rw] items
      # @return [Array<Object>]
      model_attr :items, writable: true, default: [], referenceable_list: true
      # item in the XSD
      # @!attribute [rw] organizations
      # @return [Array<Organization>]
      model_attr :organizations, writable: true, default: [], referenceable_list: true
      # @return [Array<AnyElement>]
      model_attr :other_elements, default: []
      # @return [Array<AnyAttribute>]
      model_attr :other_attributes, default: []

      def to_s
        "#{Archimate::Color.data_model('Organization')}<#{id}>[#{Archimate::Color.color(name, %i[white underline])}]"
      end

      def referenced_identified_nodes
        organizations.reduce(items) do |a, e|
          a.to_ary + e.referenced_identified_nodes
        end
      end

      def remove(id)
        items.delete_if { |item| item.id == id }
      end
    end
  end
end
