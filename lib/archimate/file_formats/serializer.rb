# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      autoload :NamedCollection, 'archimate/file_formats/serializer/named_collection'
      autoload :Writer, 'archimate/file_formats/serializer/writer'
      autoload :XmlLangString, 'archimate/file_formats/serializer/xml_lang_string'
      autoload :XmlMetadata, 'archimate/file_formats/serializer/xml_metadata'
      autoload :XmlPropertyDefs, 'archimate/file_formats/serializer/xml_property_defs'
      module Archi
        autoload :Bounds, 'archimate/file_formats/serializer/archi/bounds'
        autoload :Connection, 'archimate/file_formats/serializer/archi/connection'
        autoload :Diagram, 'archimate/file_formats/serializer/archi/diagram'
        autoload :Documentation, 'archimate/file_formats/serializer/archi/documentation'
        autoload :Element, 'archimate/file_formats/serializer/archi/element'
        autoload :Model, 'archimate/file_formats/serializer/archi/model'
        autoload :Organization, 'archimate/file_formats/serializer/archi/organization'
        autoload :Property, 'archimate/file_formats/serializer/archi/property'
        autoload :Relationship, 'archimate/file_formats/serializer/archi/relationship'
        autoload :ViewNode, 'archimate/file_formats/serializer/archi/view_node'
        autoload :ViewpointType, 'archimate/file_formats/serializer/archi/viewpoint_type'
      end
      module ModelExchangeFile
        autoload :Element, 'archimate/file_formats/serializer/model_exchange_file/element'
        autoload :Location, 'archimate/file_formats/serializer/model_exchange_file/location'
        autoload :ModelExchangeFileWriter, 'archimate/file_formats/serializer/model_exchange_file/model_exchange_file_writer'
        autoload :Organization, 'archimate/file_formats/serializer/model_exchange_file/organization'
        autoload :Properties, 'archimate/file_formats/serializer/model_exchange_file/properties'
        autoload :Relationship, 'archimate/file_formats/serializer/model_exchange_file/relationship'
        autoload :Style, 'archimate/file_formats/serializer/model_exchange_file/style'
        module V21
          autoload :Connection, 'archimate/file_formats/serializer/model_exchange_file/v21/connection'
          autoload :Diagram, 'archimate/file_formats/serializer/model_exchange_file/v21/diagram'
          autoload :Item, 'archimate/file_formats/serializer/model_exchange_file/v21/item'
          autoload :Label, 'archimate/file_formats/serializer/model_exchange_file/v21/label'
          autoload :Model, 'archimate/file_formats/serializer/model_exchange_file/v21/model'
          autoload :OrganizationBody, 'archimate/file_formats/serializer/model_exchange_file/v21/organization_body'
          autoload :Property, 'archimate/file_formats/serializer/model_exchange_file/v21/property'
          autoload :ViewNode, 'archimate/file_formats/serializer/model_exchange_file/v21/view_node'
        end
        module V30
          autoload :Connection, 'archimate/file_formats/serializer/model_exchange_file/v30/connection'
          autoload :Diagram, 'archimate/file_formats/serializer/model_exchange_file/v30/diagram'
          autoload :Item, 'archimate/file_formats/serializer/model_exchange_file/v30/item'
          autoload :Label, 'archimate/file_formats/serializer/model_exchange_file/v30/label'
          autoload :Model, 'archimate/file_formats/serializer/model_exchange_file/v30/model'
          autoload :OrganizationBody, 'archimate/file_formats/serializer/model_exchange_file/v30/organization_body'
          autoload :Property, 'archimate/file_formats/serializer/model_exchange_file/v30/property'
          autoload :PropertyDefinitions, 'archimate/file_formats/serializer/model_exchange_file/v30/property_definitions'
          autoload :ViewNode, 'archimate/file_formats/serializer/model_exchange_file/v30/view_node'
        end
      end
    end
  end
end
