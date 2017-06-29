# frozen_string_literal: true
module Archimate
  module DataModel
    PositiveInteger = Strict::Int.constrained(gt: 0)

    # Graphical node type. It can contain child node types.
    # TODO: This is ViewNodeType in the v3 XSD
    class ViewNode < Referenceable #  < ViewConcept
      using DiffableArray

      # LocationGroup: TODO: Consider making this a mixin or extract object
      # The x (towards the right, associated with width) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      # attribute :x, NonNegativeInteger
      # The y (towards the bottom, associated with height) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      # attribute :y, NonNegativeInteger

      # SizeGroup:
      # The width (associated with x) attribute from the Left side to the right side of the
      # bounding box of a concept.
      # attribute :w, PositiveInteger
      # The height (associated with y) attribute from the top side to the bottom side of the
      # bounding box of a concept.
      # attribute :h, PositiveInteger

      attribute :model, Strict::String.optional
      attribute :content, Strict::String.optional
      attribute :target_connections, Strict::Array.member(Strict::String).default([])
      attribute :archimate_element, Strict::String.optional
      attribute :bounds, Bounds.optional
      attribute :nodes, Strict::Array.member(ViewNode).default([])
      attribute :connections, ConnectionList
      attribute :style, Style.optional
      attribute :type, Strict::String.optional
      attribute :child_type, Coercible::Int.optional
      attribute :properties, PropertiesList # Note: this is not in the model under element
      # it's added under Real Element

      def replace(entity, with_entity)
        if (archimate_element == entity.id)
          @archimate_element = with_entity.id
          @element = with_entity
        end
        if (model == entity.id)
          @model = with_entity.id
          @model_element = with_entity
        end
      end

      def to_s
        "ViewNode[#{name || ''}](#{in_model.lookup(archimate_element) if archimate_element && in_model})"
      end

      def description
        [
          name.nil? ? nil : name.to_s,
          element.nil? ? nil : element.name,
          element&.type.nil? ? nil : "(#{element.type})"
        ].compact.join(" ")
      end

      def element
        @element ||= in_model.lookup(archimate_element)
      end

      def model_element
        @model_element ||= in_model.lookup(model)
      end

      def all_nodes
        nodes.inject(Array.new(nodes)) { |child_ary, child| child_ary.concat(child.all_nodes) }
      end

      def child_id_hash
        nodes.each_with_object(id => self) { |i, a| a.merge!(i.child_id_hash) }
      end

      def referenced_identified_nodes
        (nodes + connections).reduce(
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
        el = parent.parent
        while el.respond_to?(:bounds) && el.bounds
          bounds = el.bounds
          offset = offset.with(x: (offset.x || 0) + (bounds.x || 0), y: (offset.y || 0) + (bounds.y || 0))
          el = el.parent.parent
        end
        offset
      end
    end

    Dry::Types.register_class(ViewNode)
  end
end

# Type is one of:  ["archimate:DiagramModelReference", "archimate:Group", "archimate:DiagramObject"]
# textAlignment "2"
# model is on only type of archimate:DiagramModelReference and is id of another element type=archimate:ArchimateDiagramModel
# fillColor, lineColor, fontColor are web hex colors
# targetConnections is a string of space separated ids to connections on diagram objects found on DiagramObject
# archimateElement is an id of a model element found on DiagramObject types
# font is of this form: font="1|Arial|14.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Arial"
