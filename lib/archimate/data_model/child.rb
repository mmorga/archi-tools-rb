# frozen_string_literal: true
module Archimate
  module DataModel
    class Child < IdentifiedNode
      using DiffableArray

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

      def to_s
        "Child[#{name || ''}](#{in_model.lookup(archimate_element) if archimate_element && in_model})"
      end

      def description
        [
          name.nil? ? nil : "#{name}",
          element.nil? ? nil : element.name,
          element&.type.nil? ? nil : "(#{element.type})",
        ].compact.join(" ")
      end

      def element
        @element ||= in_model.lookup(archimate_element)
      end

      def all_children
        children.inject(Array.new(children)) { |child_ary, child| child_ary.concat(child.all_children) }
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

      def in_diagram
        @diagram ||= ->(node) { node = node.parent until node.nil? || node.is_a?(Diagram) }.call(self)
      end

      # TODO: Is this true for all or only Archi models?
      def absolute_position
        offset = bounds || Archimate::DataModel::Bounds.zero
        el = self.parent.parent
        while el.respond_to?(:bounds) && el.bounds
          bounds = el.bounds
          offset = offset.with(x: (offset.x || 0) + (bounds.x || 0), y: (offset.y || 0) + (bounds.y || 0))
          el = el.parent.parent
        end
        offset
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
