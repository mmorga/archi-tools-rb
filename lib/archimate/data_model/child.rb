# frozen_string_literal: true
module Archimate
  module DataModel
    class Child < IdentifiedNode
      attribute :model, Strict::String.optional
      attribute :name, Strict::String.optional
      attribute :content, Strict::String.optional
      attribute :target_connections, Strict::Array.member(Strict::String).default([])
      attribute :archimate_element, Strict::String.optional
      attribute :bounds, Bounds.optional
      attribute :children, Strict::Array.member(Child).default([])
      attribute :source_connections, SourceConnectionList
      attribute :style, Style.optional
      attribute :child_type, Coercible::Int.optional

      def clone
        Child.new(
          id: id.clone,
          type: type&.clone,
          model: model&.clone,
          name: name&.clone,
          content: content&.clone,
          target_connections: target_connections&.clone,
          archimate_element: archimate_element&.clone,
          bounds: bounds&.clone,
          children: children.map(&:clone),
          source_connections: source_connections.map(&:clone),
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          style: style&.clone,
          child_type: child_type
        )
      end

      def element_references
        children.each_with_object([archimate_element]) do |i, a|
          a.concat(i.element_references)
        end
      end

      def relationships
        children.each_with_object(source_connections.map(&:relationship).compact) do |i, a|
          a.concat(i.relationships)
        end
      end

      def to_s
        "Child[#{name || ''}](#{in_model.lookup(archimate_element) if archimate_element && in_model})"
      end

      def element
        in_model.lookup(archimate_element)
      end

      def all_source_connections
        source_connections + children.each_with_object([]) { |i, a| a.concat(i.all_source_connections) }
      end

      def child_id_hash
        children.each_with_object(id => self) { |i, a| a.merge!(i.child_id_hash) }
      end

      def referenced_identified_nodes
        (children + source_connections).reduce(
          (target_connections + [archimate_element]).compact
        ) do |a, e|
          a.concat(e.referenced_identified_nodes)
        end
      end
    end

    Dry::Types.register_class(Child)
  end
end

# Type is one of:  ["archimate:DiagramModelReference", "archimate:Group", "archimate:DiagramObject"]
# textAlignment "2"
# model is on only type of archimate:DiagramModelReference and is id of another element type=archimate:ArchimateDiagramModel
# fillColor, lineColor, fontColor are web hex colors
# targetConnections is a string of space separated ids to connections on diagram objects found on DiagramObject
# archimateElement is an id of a model element found on DiagramObject types
# font is of this form: font="1|Arial|14.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Arial"
