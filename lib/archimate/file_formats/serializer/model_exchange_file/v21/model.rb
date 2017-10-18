# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module Model
            def serialize_model(xml, model)
              xml.model(model_attrs) do
                Serializer::XmlMetadata.new(model.metadata).serialize(xml)
                Serializer::XmlLangString.new(model.name, :name).serialize(xml)
                Serializer::XmlLangString.new(model.documentation, :documentation).serialize(xml)
                serialize_properties(xml, model)
                Serializer::NamedCollection.new("elements", model.elements).serialize(xml) { |xml_e, elements| serialize(xml_e, elements) }
                Serializer::NamedCollection.new("relationships", model.relationships).serialize(xml) { |xml_r, relationships| serialize(xml_r, relationships) }
                NamedCollection.new("organization", model.organizations).serialize(xml) { |xml_o, orgs|  serialize(xml_o, orgs) }
                Serializer::XmlPropertyDefs.new(model.property_definitions).serialize(xml)
                NamedCollection.new("views", model.diagrams).serialize(xml) do |xml_v, diagrams|
                  serialize(xml_v, diagrams)
                end
              end
            end

            def model_attrs
              model.namespaces.merge(
                "xsi:schemaLocation" => model.schema_locations.join(" "),
                "identifier" => identifier(model.id)
              )
            end
          end
        end
      end
    end
  end
end
