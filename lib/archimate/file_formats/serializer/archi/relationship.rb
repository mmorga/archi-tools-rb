# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Relationship
          def serialize_relationship(xml, rel)
            xml.element(
              remove_nil_values(
                "xsi:type" => "archimate:#{rel.type}Relationship",
                "id" => rel.id,
                "name" => rel.name,
                "source" => rel.source.id,
                "target" => rel.target.id,
                "accessType" => serialize_access_type(rel.access_type)
              )
            ) do
              serialize_documentation(xml, rel.documentation)
              serialize(xml, rel.properties)
            end
          end

          def serialize_access_type(val)
            case val
            when nil
              nil
            else
              DataModel::ACCESS_TYPE.index(val)
            end
          end
        end
      end
    end
  end
end
