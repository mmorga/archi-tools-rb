# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module Properties
          def serialize_properties(xml, element)
            NamedCollection.new("properties", element.properties).serialize(xml) { |xml_p, props|  serialize(xml_p, props) }
          end
        end
      end
    end
  end
end
