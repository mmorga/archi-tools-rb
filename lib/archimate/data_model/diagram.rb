# frozen_string_literal: true
module Archimate
  module DataModel
    class Diagram < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :id, Identifier
      attribute :name, LangString
      attribute :documentation, PreservedLangString.optional.default(nil)
      # attribute :other_elements, Strict::Array.member(AnyElement).default([])
      # attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])
      attribute :type, Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      attribute :properties, Strict::Array.member(Property).default([])
      attribute :viewpoint_type, Strict::String.optional.default(nil) # TODO: ViewpointType.optional is better, but is ArchiMate version dependent. Need to figure that out
      attribute :viewpoint, Viewpoint.optional.default(nil)
      attribute :nodes, Strict::Array.member(ViewNode).default([])
      attribute :connection_router_type, Coercible::Int.optional.default(nil) # TODO: Archi formats only fill this in, should be an enum
      attribute :background, Coercible::Int.optional.default(nil) # value of 0 on Archi Sketch Model
      attribute :connections, Strict::Array.member(Connection).default([])

      attr_writer :nodes
      attr_writer :connections

      def dup
        raise "no dup dum dum"
      end

      def clone
        raise "no clone dum dum"
      end

      def all_nodes
        nodes.inject(Array.new(nodes)) { |child_ary, child| child_ary.concat(child.all_nodes) }
      end

      def elements
        @elements ||= all_nodes.map(&:element).compact
      end

      def element_ids
        @element_ids ||= elements.map(&:id)
      end

      def relationships
        @relationships ||= connections.map(&:relationship).compact
      end

      def relationship_ids
        @relationship_ids ||= relationships.map(&:id)
      end

      def to_s
        "#{Archimate::Color.data_model('Diagram')}<#{id}>[#{Archimate::Color.color(name, [:white, :underline])}]"
      end

      def total_viewpoint?
        viewpoint_type.nil? || viewpoint_type.empty?
      end
    end
    Dry::Types.register_class(Diagram)
  end
end
