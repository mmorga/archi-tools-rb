module Archimate
  module DataModel
    class ModelingNote < ArchimateNode
      attribute :documentation, Strict::Array.members(Documentation).default([])
      attribute :type, Strict::String.optional
    end
  end
end
