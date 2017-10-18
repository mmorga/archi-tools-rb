# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module Item
            def serialize_item(xml, item)
              xml.item(identifierref: identifier(item.id))
            end
          end
        end
      end
    end
  end
end
