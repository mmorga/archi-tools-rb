# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        ELEMENT_CLASS = Hash.new(Sax::AnyElement).merge(
          "model" => Model,
          "documentation" => Sax::PreservedLangString,
          "purpose" => Sax::PreservedLangString,
          "metadata" => Metadata,
          "schema" => Sax::ContentElement,
          "schemaversion" => Sax::ContentElement,
          "textPosition" => Sax::ContentElement,
          "schemaInfo" => SchemaInfo,
          "name" => Sax::LangString,
          "value" => Sax::LangString,
          "label" => Sax::LangString,
          "properties" => Sax::NoOp,
          "elements" => Sax::NoOp,
          "relationships" => Sax::NoOp,
          "organization" => Sax::NoOp,
          "organizations" => Sax::NoOp,
          "propertydefs" => Sax::NoOp,
          "propertyDefinitions" => Sax::NoOp,
          "views" => Sax::NoOp,
          "diagrams" => Sax::NoOp,
          "property" => Property,
          "element" => Element,
          "relationship" => Relationship,
          "item" => Item,
          "propertydef" => PropertyDefinition,
          "propertyDefinition" => PropertyDefinition,
          "view" => Diagram,
          "node" => ViewNode,
          "style" => Style,
          "fillColor" => Color,
          "lineColor" => Color,
          "color" => Color,
          "connection" => Connection,
          "bendpoint" => Location,
          "font" => Font
        )

        class ModelExchangeHandlerFactory
          def handler_for(name, _attrs)
            ELEMENT_CLASS[name]
          end
        end
      end
    end
  end
end
