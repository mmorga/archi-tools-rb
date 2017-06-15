# frozen_string_literal: true
module Archimate
  module DataModel
    class Diagram < View
      attribute :children, Strict::Array.member(ViewNode).default([])
      # TODO: attribute :nodes, Strict::Array.member(ViewNode).default([])
      attribute :connection_router_type, Coercible::Int.optional # TODO: Archi formats only fill this in, should be an enum
      attribute :background, Coercible::Int.optional # value of 0 on Archi Sketch Model
      attribute :connections, Strict::Array.member(Connection).default([]) # TODO this is Connection in Archi formats

      def all_children
        children.inject(Array.new(children)) { |child_ary, child| child_ary.concat(child.all_children) }
      end

      # def all_connections
      #   children.inject([]) { |child_ary, child| child_ary.concat(child.all_connections) }
      # end

      def elements
        @elements ||= all_children.map(&:element).compact
      end

      def element_ids
        @element_ids ||= all_children.map(&:archimate_element).compact
      end

      def relationships
        @relationships ||= connections.map(&:element).compact
      end

      def relationship_ids
        @relationship_ids ||= connections.map(&:relationship).compact
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
