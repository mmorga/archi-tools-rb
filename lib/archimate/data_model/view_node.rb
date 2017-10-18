# frozen_string_literal: true

module Archimate
  module DataModel
    # PositiveInteger =Int.constrained(gt: 0)

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
      # @!attribute [r] id
      #   @return [String]
      model_attr :id
      # @!attribute [r] name
      #   @return [LangString, NilClass]
      model_attr :name
      # @!attribute [r] documentation
      #   @return [PreservedLangString, NilClass]
      model_attr :documentation
      # # @!attribute [r] other_elements
      #   @return [Array<AnyElement>]
      model_attr :other_elements
      # # @!attribute [r] other_attributes
      #   @return [Array<AnyAttribute>]
      model_attr :other_attributes
      # @note type here was used for the Element/Relationship/Diagram type
      # @!attribute [r] type
      #   @return [String, NilClass]
      model_attr :type
      # @!attribute [r] style
      #   @return [Style, NilClass]
      model_attr :style

      # @note viewRefs are pointers to 0-* Diagrams for diagram drill in defined in abstract View Concept
      # @todo Make this an array
      # @!attribute [rw] view_refs
      #   @return [Diagram]
      model_attr :view_refs, comparison_attr: :id, writable: true

      # @todo document where this comes from
      # @!attribute [r] content
      #   @return [String, NilClass]
      model_attr :content

      # This is needed for various calculations
      # @!attribute [r] parent
      #   @return [ViewNode]
      model_attr :parent, writable: true, comparison_attr: :no_compare

      # ViewNodeType
      # @!attribute [r] bounds
      #   @return [Bounds, NilClass]
      model_attr :bounds

      # Container - container doesn't distinguish between nodes and connections
      # @!attribute [r] nodes
      #   @return [Array<ViewNode>]
      model_attr :nodes
      # @!attribute [r] connections
      #   @return [Array<Connection>]
      model_attr :connections

      # @note properties is not in the model under element, it's added under Real Element
      # @todo Delete this - I think it's not used
      # @!attribute [r] properties
      #   @return [Array<Property>]
      model_attr :properties

      # Element
      # @!attribute [rw] element
      #   @return [Element, NilClass]
      model_attr :element, writable: true, comparison_attr: :id
      # Archi format, selects the shape of element (for elements that can have two or more shapes)
      # @!attribute [r] child_type
      #   @return [Int, NilClass]
      model_attr :child_type

      # @!attribute [r] diagram
      #   @return [Diagram, NilClass]
      model_attr :diagram, comparison_attr: :no_compare

      # Node type to allow a Label in a Artifact. the "label" element holds the info for the @note.
      # Label View Nodes have the following attributes

      # conceptRef is a reference to an concept for this particular label, along with the attributeRef
      # which references the particular concept's part which this label represents.
      # @!attribute [r] concept_ref
      #   @return [String]
      model_attr :concept_ref
      # conceptRef is a reference to an concept for this particular label, along with the partRef
      # which references the particular concept's part which this label represents. If this attribute
      # is set, then there is no need to add a label tag in the Label parent (since it is contained in the model).
      # the XPATH statement is meant to be interpreted in the context of what the conceptRef points to.
      # @!attribute [r] xpath_path
      #   @return [String, NilClass]
      model_attr :xpath_path

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
        @element = with_entity if element.id == entity.id
        @view_refs = with_entity if view_refs == entity
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
          [element]
        .compact
        ) do |a, e|
          a.concat(e.referenced_identified_nodes)
        end
      end

      def in_diagram
        diagram # ||= ->(node) { node = node.parent until node.nil? || node.is_a?(Diagram) }.call(self)
      end

      # @todo Is this true for all or only Archi models?
      def absolute_position
        offset = bounds || Bounds.zero
        el = parent
        while el.respond_to?(:bounds) && el.bounds
          bounds = el.bounds
          offset = Bounds.new(offset.to_h.merge(x: (offset.x || 0) + (bounds.x || 0), y: (offset.y || 0) + (bounds.y || 0)))
          el = el.parent
        end
        offset
      end

      def target_connections
        diagram
          .connections
          .select { |conn| conn.target&.id == id }
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
