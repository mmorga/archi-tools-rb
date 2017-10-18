# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V30
          module Label
            def serialize_label(xml, str, tag = :name)
              XmlLangString.new(str, tag).serialize(xml)
            end
          end
        end
      end
    end
  end
end
