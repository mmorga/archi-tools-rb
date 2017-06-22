# frozen_string_literal: true

module Archimate
  module DataModel
    # This is a container for all of the Views in the model.
    class Views < ArchimateNode
      attribute :viewpoints, Strict::Array.member(Viewpoint).default([])
      attribute :diagrams, Strict::Array.member(Diagram).default([])
    end
    Dry::Types.register_class(Views)
  end
end
