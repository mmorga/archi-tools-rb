# frozen_string_literal: true

module Archimate
  module DataModel
    # Node type to allow a Container in a Artifact. This is a visual grouping container.
    class Container < ViewNode
      # This is to support Nested Nodes on the Diagram
      # The order of sibling nodes in their parent View or Node container as declared in the model
      # instance dictates the z-order of the nodes. Given nodes A, B, and C as declared in that order,
      # node B is considered to be in front of node A, node C is considered to be in front of node B, and
      # node C is considered to be in front of nodes A and B.
      attribute :nodes, Strict::Array.member(ViewNode)
    end

    Dry::Types.register_class(Container)
  end
end
