# frozen_string_literal: true

module Archimate
  module DataModel
    class Diagram
      include Comparison

      model_attr :id # Identifier
      model_attr :name # LangString
      model_attr :documentation # PreservedLangString.optional.default(nil)
      # model_attr :other_elements # Strict::Array.member(AnyElement).default([])
      # model_attr :other_attributes # Strict::Array.member(AnyAttribute).default([])
      model_attr :type # Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      model_attr :properties # Strict::Array.member(Property).default([])
      model_attr :viewpoint_type # Strict::String.optional.default(nil) # TODO: ViewpointType.optional is better, but is ArchiMate version dependent. Need to figure that out
      model_attr :viewpoint # Viewpoint.optional.default(nil)
      model_attr :nodes, writable: true # Strict::Array.member(ViewNode).default([])
      model_attr :connection_router_type # Coercible::Int.optional.default(nil) # TODO: Archi formats only fill this in, should be an enum
      model_attr :background # Coercible::Int.optional.default(nil) # value of 0 on Archi Sketch Model
      model_attr :connections, writable: true # Strict::Array.member(Connection).default([])

      def initialize(id:, name:, documentation: nil, type: nil, properties: [],
                     viewpoint_type: nil, viewpoint: nil, nodes: [],
                     connection_router_type: nil, background: nil, connections: [])
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @properties = properties
        @viewpoint_type = viewpoint_type
        @viewpoint = viewpoint
        @nodes = nodes
        @connection_router_type = connection_router_type
        @background = background
        @connections = connections
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
        "#{Archimate::Color.data_model('Diagram')}<#{id}>[#{Archimate::Color.color(name, %i[white underline])}]"
      end

      def total_viewpoint?
        viewpoint_type.nil? || viewpoint_type.empty?
      end

      def referenced_identified_nodes
        (nodes + connections)
          .map(&:referenced_identified_nodes)
          .flatten
          .uniq
      end
    end
  end
end
