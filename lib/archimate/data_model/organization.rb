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
    class Organization < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :id, Identifier.optional # .constrained(format: /[[[:alpha:]]_][w-.]*/)
      attribute :name, LangString.optional.default(nil) # LabelGroup in the XSD
      attribute :type, Strict::String.optional.default(nil) # I believe this is used only for Archi formats
      attribute :documentation, PreservedLangString.optional.default(nil)
      attribute :items, Strict::Array.member(Dry::Struct).default([])
      attribute :organizations, Strict::Array.member(Organization).default([]) # item in the XSD
      # attribute :other_elements, Strict::Array.member(AnyElement).default([])
      # attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])

      def dup
        raise "no dup dum dum"
      end

      def clone
        raise "no clone dum dum"
      end

      def to_s
        "#{Archimate::Color.data_model('Organization')}<#{id}>[#{Archimate::Color.color(name, [:white, :underline])}]"
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
    Dry::Types.register_class(Organization)
  end
end
