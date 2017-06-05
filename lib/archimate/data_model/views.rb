module Archimate
  module DataModel
    class Views < ArchimateNode
      attribute :viewpoints, Strict::Array.members(Viewpoint).default([])
    end
  end
end
