# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Organization
          def serialize_organization(xml, organization)
            xml.folder(
              remove_nil_values(name: organization.name, id: organization.id, type: organization.type)
            ) do
              serialize(xml, organization.organizations)
              serialize_documentation(xml, organization.documentation)
              serialize(xml, organization.items)
            end
          end
        end
      end
    end
  end
end
