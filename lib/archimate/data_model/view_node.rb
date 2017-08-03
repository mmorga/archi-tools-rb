# frozen_string_literal: true
module Archimate
  module DataModel
    PositiveInteger = Strict::Int.constrained(gt: 0)

    # Graphical node type. It can contain child node types.
    # This can be specialized as Label and Container
    # In the ArchiMate v3 Schema, the tree of these nodes is:
    # ViewConceptType(
    #     LabelGroup (name LangString)
    #     PreservedLangString
    #     style (optional)
    #     viewRefs
    #     id)
    # - ViewNodeType(
    #       LocationGroup (x, y)
    #       SizeGroup (width, height))
    #   - Label(
    #         conceptRef
    #         attributeRef
    #         xpathPart (optional)
    #     )
    #   - Container(
    #         nodes (ViewNodeType)
    #     - Element(
    #           elementRef)
    class ViewNode < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      using DiffableArray

      # ViewConceptType
      attribute :id, Identifier
      attribute :name, LangString.optional.default(nil)
      attribute :documentation, PreservedLangString.optional.default(nil)
      # attribute :other_elements, Strict::Array.member(AnyElement).default([])
      # attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])
      attribute :type, Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      attribute :style, Style.optional.default(nil)

      # TODO: viewRefs are pointers to 0-* Diagrams for diagram drill in defined in abstract View Concept
      attribute :view_refs, Dry::Struct.optional.default(nil)  # viewRef in XSD for a nested View Concept(s) TODO: Make this an array

      # TODO: document where this comes from
      attribute :content, Strict::String.optional.default(nil)

      # ViewNodeType
      attribute :bounds, Bounds.optional.default(nil)

      # Container - container doesn't distinguish between nodes and connections
      attribute :nodes, Strict::Array.member(ViewNode).default([])
      attribute :connections, Strict::Array.member(Connection).default([])

      # Note: properties is not in the model under element
      # it's added under Real Element
      # TODO: Delete this - I think it's not used
      attribute :properties, Strict::Array.member(Property).default([])

      # Element
      attribute :element, Element.optional.default(nil)
      attribute :child_type, Coercible::Int.optional.default(nil) # Archi format, selects the shape of element (for elements that can have two or more shapes)

      attribute :diagram, Dry::Struct # Actually a Diagram, but impossible due to circular reference

      attr_writer :view_refs
      attr_writer :element
      attr_writer :nodes
      attr_writer :connections

      def dup
        raise "no dup dum dum"
      end

      def clone
        raise "no clone dum dum"
      end

      def replace(entity, with_entity)
        if (element.id == entity.id)
          @element = with_entity
        end
        if (view_refs == entity)
          @view_refs = with_entity
        end
      end

      def to_s
        "ViewNode[#{name || ''}](#{element if element})"
      end

      def description
        [
          name.nil? ? nil : name.to_s,
          element.nil? ? nil : element.name,
          element&.type.nil? ? nil : "(#{element.type})"
        ].compact.join(" ")
      end

      def all_nodes
        nodes.inject(Array.new(nodes)) { |child_ary, child| child_ary.concat(child.all_nodes) }
      end

      def child_id_hash
        nodes.each_with_object(id => self) { |i, a| a.merge!(i.child_id_hash) }
      end

      def referenced_identified_nodes
        (nodes + connections).reduce(
          (
            [element]
          ).compact
        ) do |a, e|
          a.concat(e.referenced_identified_nodes)
        end
      end

      def in_diagram
        diagram # ||= ->(node) { node = node.parent until node.nil? || node.is_a?(Diagram) }.call(self)
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

      def target_connections
        diagram
          .connections
          .select{ |conn| conn.target == self }
          .map(&:id)
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
