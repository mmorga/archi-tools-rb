# frozen_string_literal: true

module Archimate
  module FileFormats
    class ModelExchangeFile
      class Model
        def parse_model(root)
          @property_defs = parse_property_defs(root) # TODO: move to properties
          DataModel::Model.new(
            id: identifier_to_id(root["identifier"]),
            name: parse_name(root),
            documentation: parse_documentation(root),
            properties: parse_properties(root),
            elements: parse_elements(root),
            relationships: parse_relationships(root),
            organizations: parse_organizations(root.css(">organization>item")),
            diagrams: parse_diagrams(root)
          )
        end
      end
    end
  end
end
