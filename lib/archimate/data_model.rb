module Archimate
  module DataModel
    include Dry::Types.module

    Coercible = Archimate::DataModel::Coercible
    Strict = Archimate::DataModel::Strict

    DocumentationList = Strict::Array.member('strict.string') # Strict::String)

    require 'archimate/data_model/property'
    require 'archimate/data_model/bendpoint'
    require 'archimate/data_model/bounds'
    require 'archimate/data_model/source_connection'
    require 'archimate/data_model/child'
    require 'archimate/data_model/diagram'
    require 'archimate/data_model/element'
    require 'archimate/data_model/folder'
    require 'archimate/data_model/organization'
    require 'archimate/data_model/model'
    require 'archimate/data_model/relationship'
  end
end
