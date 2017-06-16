# frozen_string_literal: true

module Archimate
  module DataModel
    include Dry::Types.module

    Coercible = Archimate::DataModel::Coercible
    Strict = Archimate::DataModel::Strict

    # Identifiers in the ArchiMate exchange format standard are of
    Identifier = Strict::String # .constrained(format: /[[[:alpha:]]_][\w\-\.]*/)

    # An enumeration of data types.
    DataType = Strict::String.default("string").enum("string", "boolean", "currency", "date", "time", "number")

    # Enumeration of Influence Strength types. These are suggestions.
    InfluenceStrengthEnum = Strict::String.enum(%w[+ ++ - -- 0 1 2 3 4 5 6 7 8 9 10])

    require 'archimate/data_model/diffable_primitive'
    require 'archimate/data_model/diffable_array'
    require 'archimate/data_model/constants'
    require 'archimate/data_model/archimate_node'
    require 'archimate/data_model/lang_string'
    require 'archimate/data_model/preserved_lang_string'
    require 'archimate/data_model/schema_info'
    require 'archimate/data_model/metadata'
    require 'archimate/data_model/color'
    require 'archimate/data_model/font'
    require 'archimate/data_model/style'
    require 'archimate/data_model/property'
    require 'archimate/data_model/bounds'
    require 'archimate/data_model/documentation'
    require 'archimate/data_model/modeling_note'
    require 'archimate/data_model/referenceable'
    require 'archimate/data_model/named_referenceable'
    require 'archimate/data_model/property_definition'
    require 'archimate/data_model/concept'
    require 'archimate/data_model/organization'
    require 'archimate/data_model/element'
    require 'archimate/data_model/relationship'
    require 'archimate/data_model/concern'
    require 'archimate/data_model/viewpoint'
    require 'archimate/data_model/view'
    require 'archimate/data_model/view_concept'
    require 'archimate/data_model/location'
    require 'archimate/data_model/connection'
    require 'archimate/data_model/view_node'
    require 'archimate/data_model/container'
    require 'archimate/data_model/diagram'
    require 'archimate/data_model/views'
    require 'archimate/data_model/label'
    require 'archimate/data_model/model'
  end
end
