# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module Relationship
          def serialize_relationship(xml, relationship)
            xml.relationship(
              relationship_attributes(relationship)
            ) do
              elementbase(xml, relationship)
            end
          end
        end
      end
    end
  end
end
