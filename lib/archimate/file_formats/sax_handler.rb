# frozen_string_literal: true

module Archimate
  module FileFormats
    SaxEvent = Struct.new(:sym, :args, :source)
    FutureReference = Struct.new(:obj, :attr, :id)

    class SaxHandler
      attr_reader :attrs
      attr_reader :parent_handler
      attr_reader :element_type

      def initialize(attrs, parent_handler)
        @attrs = Hash[attrs]
        @parent_handler = parent_handler
        @element_type = @attrs["xsi:type"]&.sub(/archimate:/, '')
      end

      def characters(string)
      end

      # @return [Array<Event>] array of events to fire for this handler
      def complete
        []
      end

      def diagram
        parent_handler&.diagram
      end

      def event(sym, args)
        SaxEvent.new(sym, args, self)
      end

      # @param bounds [DataModel::Bounds]
      # @param source [SaxHandler]
      def on_bounds(bounds, source)
        bounds
      end

      # @param [DataModel::Diagram]
      # @param source [SaxHandler]
      def on_diagram(diagram, source)
        diagram
      end

      # @param [DataModel::PreservedLangString]
      # @param source [SaxHandler]
      def on_preserved_lang_string(doc, source)
        doc
      end

      # @param [DataModel::Element]
      # @param source [SaxHandler]
      def on_element(element, source)
        element
      end

      # @param [FutureReference]
      # @param source [SaxHandler]
      def on_future(future, source)
        future
      end

      # @param [String]
      # @param source [SaxHandler]
      def on_content(location, source)
        location
      end

      # @param [DataModel::Location]
      # @param source [SaxHandler]
      def on_location(location, source)
        location
      end

      # @param [DataModel::Organization]
      # @param source [SaxHandler]
      def on_organization(organization, source)
        organization
      end

      # @param [DataModel::Property]
      # @param source [SaxHandler]
      def on_property(property, source)
        property
      end

      # @param [DataModel::PropertyDefinition]
      # @param source [SaxHandler]
      def on_property_definition(property_definition, source)
        property_definition
      end

      # @param [DataModel::*] any DataModel entity that responds to {#id}
      # @param source [SaxHandler]
      def on_referenceable(referenceable, source)
        referenceable
      end

      # @param [DataModel::Relationship]
      # @param source [SaxHandler]
      def on_relationship(relationship, source)
        relationship
      end

      # @param [DataModel::Style]
      # @param source [SaxHandler]
      def on_style(style, source)
        style
      end

      # @param [DataModel::ViewNode]
      # @param source [SaxHandler]
      def on_view_node(view_node, source)
        view_node
      end

      # @param [DataModel::Viewpoint]
      # @param source [SaxHandler]
      def on_viewpoint(viewpoint, source)
        viewpoint
      end

      # Returns the property definitions hash for this SaxDocument
      def property_definitions
        parent_handler&.property_definitions
      end

      def process_text(str)
        str&.gsub("&#38;", "&")
      end
    end
  end
end
