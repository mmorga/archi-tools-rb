# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Organization < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation

          def initialize(name, attrs, parent_handler)
            super
            @child_items = []
            @child_organizations = []
          end

          def complete
            organization = DataModel::Organization.new(
              id: @attrs["id"],
              name: DataModel::LangString.string(process_text(@attrs["name"])),
              type: @attrs["type"],
              documentation: documentation,
              items: @child_items,
              organizations: @child_organizations
            )
            [
              event(:on_organization, organization),
              event(:on_referenceable, organization)
            ]
          end

          def on_diagram(diagram, source)
            @child_items << diagram if source.parent_handler == self
            diagram
          end

          def on_element(element, source)
            @child_items << element if source.parent_handler == self
            element
          end

          def on_organization(organization, _source)
            @child_organizations << organization
            false
          end

          def on_relationship(relationship, source)
            @child_items << relationship if source.parent_handler == self
            relationship
          end
        end
      end
    end
  end
end
