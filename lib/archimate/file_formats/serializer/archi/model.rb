# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Model
          def serialize_model(xml, model)
            xml["archimate"].model(
              "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
              "xmlns:archimate" => "http://www.archimatetool.com/archimate",
              "name" => model.name,
              "id" => model.id,
              "version" => @version
            ) do
              serialize(xml, model.organizations)
              serialize(xml, model.properties)
              serialize_documentation(xml, model.documentation, "purpose")
            end
          end
        end
      end
    end
  end
end
