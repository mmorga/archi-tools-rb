# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Model < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @documentation = nil
          @properties = []
          @property_definitions = {}
          @elements = []
          @organizations = []
          @relationships = []
          @diagrams = []
          @viewpoints = []
          @futures = []
          @index = {}
        end

        def complete
          model = DataModel::Model.new(
            id: @attrs["id"],
            name: DataModel::LangString.string(@attrs["name"]),
            documentation: @documentation,
            properties: @properties,
            elements: @elements,
            organizations: @organizations,
            relationships: @relationships,
            diagrams: @diagrams,
            viewpoints: @viewpoints,
            property_definitions: @property_definitions.values,
            namespaces: {},
            schema_locations: [],
            version: @attrs["version"]
          )
          @futures.each do |future|
            future.obj.send(
              "#{future.attr}=".to_sym,
              case future.id
              when Array
                future.id.map { |id| @index[id] }
              else
                @index[future.id]
              end
            )
          end
          [event(:on_model, model)]
        end

        def on_documentation(doc, source)
          @documentation = doc
          false
        end

        def on_property(property, source)
          @properties << property
          false
        end

        def on_element(element, source)
          @elements << element
          false
        end

        def on_organization(organization, source)
          @organizations << organization
          false
        end

        def on_relationship(relationship, source)
          @relationships << relationship
          false
        end

        def on_diagram(diagram, source)
          @diagrams << diagram
          false
        end

        def on_viewpoint(viewpoint, source)
          @viewpoints << viewpoint
          false
        end

        def on_property_definition(property_definition, source)
          @property_definitions[property_definition.id] = property_definition
          false
        end

        def on_future(future, source)
          @futures << future
        end

        def on_referenceable(referenceable, source)
          @index[referenceable.id] = referenceable
        end

        def property_definitions
          @property_definitions
        end
      end
    end
  end
end
