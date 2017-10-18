# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      class NamedCollection
        def initialize(name, collection)
          @name = name
          @collection = collection
        end

        def serialize(xml, &block)
          return unless @collection&.size&.positive?
          xml.send(@name) do
            block.call(xml, @collection)
          end
        end
      end
    end
  end
end
