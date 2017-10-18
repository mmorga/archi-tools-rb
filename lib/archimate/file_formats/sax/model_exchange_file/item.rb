# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class Item < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation

          def initialize(name, attrs, parent_handler)
            super
            @item_name = nil
            @child_items = []
            @child_organizations = []
            @identifier_ref = nil
            @organization = nil
          end

          def complete
            return [event(:on_item_reference, identifier_ref)] if identifier_ref

            [
              event(:on_organization, organization),
              event(:on_referenceable, organization),
              event(:on_future, Sax::FutureReference.new(organization, :items, @child_items))
            ]
          end

          def on_organization(organization, _source)
            @child_organizations << organization
            false
          end

          def on_item_reference(ref, _source)
            @child_items << ref
            false
          end

          def on_lang_string(name, _source)
            @item_name = name
            false
          end

          private

          def organization
            @organization ||= DataModel::Organization.new(
              id: attrs["identifier"], # TODO: model exchange doesn't assign ids to organization items
              name: @item_name,
              type: attrs["type"],
              documentation: documentation,
              items: nil,
              organizations: @child_organizations
            )
          end

          def identifier_ref
            @identifier_ref ||= attrs["identifierRef"] || attrs["identifierref"]
          end
        end
      end
    end
  end
end
