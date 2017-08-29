# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Model < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          attr_reader :property_definitions

          def initialize(name, attrs, parent_handler)
            super
            @property_definitions = {}
            @elements = []
            @organizations = []
            @relationships = []
            @diagrams = []
            @viewpoints = []
            @futures = []
            @index = {}
            @model = nil
          end

          def complete
            process_futures
            [event(:on_model, model)]
          end

          def on_element(element, _source)
            @elements << element
            false
          end

          def on_organization(organization, _source)
            @organizations << organization
            false
          end

          def on_relationship(relationship, _source)
            @relationships << relationship
            false
          end

          def on_diagram(diagram, _source)
            @diagrams << diagram
            false
          end

          def on_viewpoint(viewpoint, _source)
            @viewpoints << viewpoint
            false
          end

          def on_property_definition(property_definition, _source)
            @property_definitions[property_definition.id] = property_definition
            false
          end

          def on_future(future, _source)
            @futures << future
          end

          def on_referenceable(referenceable, _source)
            @index[referenceable.id] = referenceable
          end

          private

          def process_futures
            @futures.each do |future|
              future.obj.send(
                "#{future.attr}=".to_sym,
                if future.id.is_a?(Array)
                  future.id.map { |id| @index[id] }
                else
                  @index[future.id]
                end
              )
            end
          end

          def model
            @model ||= DataModel::Model.new(id: @attrs["id"],
                                            name: DataModel::LangString.string(process_text(@attrs["name"])),
                                            documentation: documentation,
                                            properties: properties,
                                            elements: @elements,
                                            organizations: @organizations,
                                            relationships: @relationships,
                                            diagrams: @diagrams,
                                            viewpoints: @viewpoints,
                                            property_definitions: @property_definitions.values,
                                            namespaces: {},
                                            schema_locations: [],
                                            version: @attrs["version"])
          end
        end
      end
    end
  end
end
