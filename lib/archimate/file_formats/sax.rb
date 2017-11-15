# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      SaxEvent = Struct.new(:sym, :args, :source)
      FutureReference = Struct.new(:obj, :attr, :id)

      autoload :AnyElement, 'archimate/file_formats/sax/any_element'
      autoload :CaptureContent, 'archimate/file_formats/sax/capture_content'
      autoload :CaptureDocumentation, 'archimate/file_formats/sax/capture_documentation'
      autoload :CaptureProperties, 'archimate/file_formats/sax/capture_properties'
      autoload :ContentElement, 'archimate/file_formats/sax/content_element'
      autoload :Document, 'archimate/file_formats/sax/document'
      autoload :Handler, 'archimate/file_formats/sax/handler'
      autoload :LangString, 'archimate/file_formats/sax/lang_string'
      autoload :NoOp, 'archimate/file_formats/sax/no_op'
      autoload :PreservedLangString, 'archimate/file_formats/sax/preserved_lang_string'
      module Archi
        autoload :ArchiHandlerFactory, 'archimate/file_formats/sax/archi/archi_handler_factory'
        autoload :Bounds, 'archimate/file_formats/sax/archi/bounds'
        autoload :Connection, 'archimate/file_formats/sax/archi/connection'
        autoload :Content, 'archimate/file_formats/sax/archi/content'
        autoload :Diagram, 'archimate/file_formats/sax/archi/diagram'
        autoload :Element, 'archimate/file_formats/sax/archi/element'
        autoload :Location, 'archimate/file_formats/sax/archi/location'
        autoload :Model, 'archimate/file_formats/sax/archi/model'
        autoload :Organization, 'archimate/file_formats/sax/archi/organization'
        autoload :PreservedLangString, 'archimate/file_formats/sax/archi/preserved_lang_string'
        autoload :Property, 'archimate/file_formats/sax/archi/property'
        autoload :Relationship, 'archimate/file_formats/sax/archi/relationship'
        autoload :Style, 'archimate/file_formats/sax/archi/style'
        autoload :ViewNode, 'archimate/file_formats/sax/archi/view_node'
      end
      module ModelExchangeFile
        autoload :Color, 'archimate/file_formats/sax/model_exchange_file/color'
        autoload :Connection, 'archimate/file_formats/sax/model_exchange_file/connection'
        autoload :Diagram, 'archimate/file_formats/sax/model_exchange_file/diagram'
        autoload :Element, 'archimate/file_formats/sax/model_exchange_file/element'
        autoload :Font, 'archimate/file_formats/sax/model_exchange_file/font'
        autoload :Item, 'archimate/file_formats/sax/model_exchange_file/item'
        autoload :Location, 'archimate/file_formats/sax/model_exchange_file/location'
        autoload :Metadata, 'archimate/file_formats/sax/model_exchange_file/metadata'
        autoload :ModelExchangeHandlerFactory, 'archimate/file_formats/sax/model_exchange_file/model_exchange_handler_factory'
        autoload :Model, 'archimate/file_formats/sax/model_exchange_file/model'
        autoload :Property, 'archimate/file_formats/sax/model_exchange_file/property'
        autoload :PropertyDefinition, 'archimate/file_formats/sax/model_exchange_file/property_definition'
        autoload :Relationship, 'archimate/file_formats/sax/model_exchange_file/relationship'
        autoload :Schema, 'archimate/file_formats/sax/model_exchange_file/schema'
        autoload :SchemaInfo, 'archimate/file_formats/sax/model_exchange_file/schema_info'
        autoload :Style, 'archimate/file_formats/sax/model_exchange_file/style'
        autoload :ViewNode, 'archimate/file_formats/sax/model_exchange_file/view_node'
      end
    end
  end
end
