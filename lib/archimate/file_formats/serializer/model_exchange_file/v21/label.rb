# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module Label
            def serialize_label(xml, str)
              XmlLangString.new(str, :label).serialize(xml)
            end
          end
        end
      end
    end
  end
end
