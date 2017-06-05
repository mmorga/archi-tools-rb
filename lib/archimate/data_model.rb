# frozen_string_literal: true

module Archimate
  module DataModel
    include Dry::Types.module

    Coercible = Archimate::DataModel::Coercible
    Strict = Archimate::DataModel::Strict

    # Identifiers in the ArchiMate exchange format standard are of type
    # xsd:ID which must match the pattern given below.
    # This means that it must start with a letter or underscore, and can only contain
    # letters, digits, underscores, hyphens, and periods.
    Identifier = Strict::String.constrained(format: /[[[:alpha:]]_][\w\-\.]*/)

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
    require 'archimate/data_model/bendpoint'
    require 'archimate/data_model/bounds'
    require 'archimate/data_model/documentation'
    require 'archimate/data_model/identified_node'
    require 'archimate/data_model/source_connection'
    require 'archimate/data_model/child'
    require 'archimate/data_model/diagram'
    require 'archimate/data_model/folder'
    require 'archimate/data_model/element'
    require 'archimate/data_model/relationship'
    require 'archimate/data_model/model'
  end
end
