# frozen_string_literal: true
module Archimate
  module DataModel
    include Dry::Types.module

    Coercible = Archimate::DataModel::Coercible
    Strict = Archimate::DataModel::Strict

    require 'archimate/data_model/with'
    require 'archimate/data_model/color'
    require 'archimate/data_model/font'
    require 'archimate/data_model/style'
    require 'archimate/data_model/property'
    require 'archimate/data_model/bendpoint'
    require 'archimate/data_model/bounds'
    require 'archimate/data_model/documentation'
    require 'archimate/data_model/source_connection'
    require 'archimate/data_model/child'
    require 'archimate/data_model/diagram'
    require 'archimate/data_model/element'
    require 'archimate/data_model/folder'
    require 'archimate/data_model/model'
    require 'archimate/data_model/relationship'
  end
end
