# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      class Model < FileFormats::Sax::Handler
        include Sax::CaptureDocumentation
        include Sax::CaptureProperties

        def initialize(name, attrs, parent_handler)
          super
          @property_definitions = {}
          @elements = []
          @organizations = []
          @relationships = []
          @diagrams = []
          @viewpoints = []
          @futures = []
          @metadata = nil
          @index = {}
        end

        def complete
          namespaces = @attrs.select { |k, v| k.start_with?("xmlns") }
          model = DataModel::Model.new(
            id: attrs["identifier"],
            name: name,
            metadata: @metadata,
            documentation: documentation,
            properties: properties,
            elements: @elements,
            organizations: @organizations,
            relationships: @relationships,
            diagrams: @diagrams,
            viewpoints: @viewpoints,
            property_definitions: @property_definitions.values,
            schema_locations: attrs["xsi:schemaLocation"].split(" "),
            namespaces: namespaces,
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

        def on_metadata(metadata, source)
          @metadata = metadata
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

        def on_any_element(any_element, source)
          raise "Unexpected: #{any_element.inspect}"
        end

        def on_lang_string(lang_string, source)
          @name = lang_string
          false
        end

        def property_definitions
          @property_definitions
        end
      end
    end
  end
end
