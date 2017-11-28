# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V30
          module Model
            def serialize_model(xml, model)
              xml.model(model_attrs(model)) do
                XmlLangString.new(model.name, :name).serialize(xml)
                XmlLangString.new(model.documentation, :documentation).serialize(xml)
                XmlMetadata.new(model.metadata).serialize(xml)
                NamedCollection.new("properties", model.properties).serialize(xml) { |xml_p, props|  serialize(xml_p, props) }
                NamedCollection.new("elements", model.elements).serialize(xml) { |xml_e, elements|  serialize(xml_e, elements) }
                NamedCollection.new("relationships", model.relationships).serialize(xml) { |xml_r, relationships|  serialize(xml_r, relationships) }
                NamedCollection.new("organizations", model.organizations).serialize(xml) { |xml_o, orgs|  serialize(xml_o, orgs) }
                PropertyDefinitions.new(model.property_definitions).serialize(xml)
                NamedCollection.new("views", model.diagrams).serialize(xml) do |xml_v, _orgs|
                  NamedCollection.new("diagrams", model.diagrams).serialize(xml_v) do |xml_d, diagrams|
                    serialize(xml_d, diagrams)
                  end
                end
              end
            end

            def model_attrs(model)
              model.namespaces.merge(
                "xsi:schemaLocation" => model.schema_locations.join(" "),
                "identifier" => identifier(model.id),
                "version" => model.version
              ).compact
            end
          end
        end
      end
    end
  end
end
