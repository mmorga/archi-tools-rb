# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module Organization
          def serialize_organization(xml, organization)
            if organization.items.empty? &&
              (!organization.documentation || organization.documentation.empty?) &&
              organization.organizations.empty?
              return
            end
            item_attrs = organization.id.nil? || organization.id.empty? ? {} : {identifier: organization.id}
            xml.item(item_attrs) do
              serialize_organization_body(xml, organization)
            end
          end
        end
      end
    end
  end
end
