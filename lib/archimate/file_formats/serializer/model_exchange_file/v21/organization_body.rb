# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module OrganizationBody
            def serialize_organization_body(xml, organization)
              if organization.items.empty? &&
                (!organization.documentation || organization.documentation.empty?) &&
                organization.organizations.empty?
                return
              end
              serialize_label(xml, organization.name)
              serialize(xml, organization.documentation)
              serialize(xml, organization.organizations)
              organization.items.each { |i| serialize_item(xml, i) }
            end
          end
        end
      end
    end
  end
end
