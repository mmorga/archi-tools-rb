# frozen_string_literal: true
module Archimate
  module DataModel
    # PositiveInteger = Strict::Int.constrained(gt: 0)

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
    class ViewNode
      include Comparison

      # ViewConceptType
      model_attr :id # Identifier
      model_attr :name # LangString.optional.default(nil)
      model_attr :documentation # PreservedLangString.optional.default(nil)
      # model_attr :other_elements # Strict::Array.member(AnyElement).default([])
      # model_attr :other_attributes # Strict::Array.member(AnyAttribute).default([])
      model_attr :type # Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      model_attr :style # Style.optional.default(nil)

      # TODO: viewRefs are pointers to 0-* Diagrams for diagram drill in defined in abstract View Concept
      model_attr :view_refs, writable: true # Dry::Struct.optional.default(nil)  # viewRef in XSD for a nested View Concept(s) TODO: Make this an array

      # TODO: document where this comes from
      model_attr :content # Strict::String.optional.default(nil)

      # This is needed for various calculations
      model_attr :parent # ViewNode

      # ViewNodeType
      model_attr :bounds # Bounds.optional.default(nil)

      # Container - container doesn't distinguish between nodes and connections
      model_attr :nodes, writable: true # Strict::Array.member(ViewNode).default([])
      model_attr :connections, writable: true # Strict::Array.member(Connection).default([])

      # Note: properties is not in the model under element
      # it's added under Real Element
      # TODO: Delete this - I think it's not used
      model_attr :properties # Strict::Array.member(Property).default([])

      # Element
      model_attr :element, writable: true # Element.optional.default(nil)
      model_attr :child_type # Coercible::Int.optional.default(nil) # Archi format, selects the shape of element (for elements that can have two or more shapes)

      model_attr :diagram # Dry::Struct # Actually a Diagram, but impossible due to circular reference


      # Node type to allow a Label in a Artifact. the "label" element holds the info for the Note.
      # Label View Nodes have the following attributes

      # conceptRef is a reference to an concept for this particular label, along with the attributeRef
      # which references the particular concept's part which this label represents.
      model_attr :concept_ref # Identifier
      # conceptRef is a reference to an concept for this particular label, along with the partRef
      # which references the particular concept's part which this label represents. If this attribute
      # is set, then there is no need to add a label tag in the Label parent (since it is contained in the model).
      # the XPATH statement is meant to be interpreted in the context of what the conceptRef points to.
      model_attr :xpath_path # Strict::String.optional

      def initialize(id:, name: nil, documentation: nil, type: nil, parent: nil,
                     style: nil, view_refs: [], content: nil, bounds: nil,
                     nodes: [], connections: [], properties: [], element: nil,
                     child_type: nil, diagram:, concept_ref: nil, xpath_path: nil)
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @parent = parent
        @style = style
        @view_refs = view_refs
        @content = content
        @bounds = bounds
        @nodes = nodes
        @connections = connections
        @properties = properties
        @element = element
        @child_type = child_type
        @diagram = diagram
        @concept_ref = concept_ref
        @xpath_path = xpath_path
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
        el = parent
        while el.respond_to?(:bounds) && el.bounds
          bounds = el.bounds
          offset = offset.with(x: (offset.x || 0) + (bounds.x || 0), y: (offset.y || 0) + (bounds.y || 0))
          el = el.parent
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
  end
end

# Type is one of:  ["archimate:DiagramModelReference", "archimate:Group", "archimate:DiagramObject"]
# textAlignment "2"
# model is on only type of archimate:DiagramModelReference and is id of another element type=archimate:ArchimateDiagramModel
# fillColor, lineColor, fontColor are web hex colors
# targetConnections is a string of space separated ids to connections on diagram objects found on DiagramObject
# archimateElement is an id of a model element found on DiagramObject types
# font is of this form: font="1|Arial|14.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Arial"
