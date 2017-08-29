# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
    module ModelExchangeFile
      class Property < FileFormats::Sax::Handler
        def initialize(name, attrs, parent_handler)
          super
          @value = nil
        end

        def complete
          property = DataModel::Property.new(property_definition: nil, value: @value)
          [
            event(:on_property, property),
            event(:on_future, Sax::FutureReference.new(property, :property_definition, @attrs["propertyDefinitionRef"] || @attrs["identifierref"]))
          ]
        end

        def on_lang_string(str, source)
          @value = str
          false
        end
      end
    end
  end
end
end
