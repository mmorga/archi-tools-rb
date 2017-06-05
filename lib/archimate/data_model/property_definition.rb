module Archimate
  module DataModel
    class PropertyDefinition < NamedReferenceable
      attribute :type, Strict::String.enum("string", "boolean", "currency", "date", "time", "number")
    end

    Dry::Types.register_class(PropertyDefinition)
  end
end
