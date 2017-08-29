# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      class ModelExchangeHandlerFactory
        def handler_for(name, attrs)
          case name
          when "model"
            Model
          when "documentation", "purpose"
            Sax::PreservedLangString
          when "metadata"
            Metadata
          when "schema", "schemaversion", "textPosition"
            Sax::ContentElement
          when "schemaInfo"
            SchemaInfo
          when "name", "value", "label"
            Sax::LangString
          when "properties",
               "elements",
               "relationships",
               "organization",
               "organizations",
               "propertydefs",
               "propertyDefinitions",
               "views",
               "diagrams"
            Sax::NoOp
          when "property"
            Property
          when "element"
            Element
          when "relationship"
            Relationship
          when "item"
            Item
          when "propertydef",
               "propertyDefinition"
            PropertyDefinition
          when "view"
            Diagram
          when "node"
            ViewNode
          when "style"
            Style
          when "fillColor", "lineColor", "color"
            Color
          when "connection"
            Connection
          when "bendpoint"
            Location
          when "font"
            Font
          else
            Sax::AnyElement
          end
        end
      end
    end
  end
end
