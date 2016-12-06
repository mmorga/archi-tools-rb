# frozen_string_literal: true
module Archimate
  module DataModel
    class IdentifiedNode < ArchimateNode
      attribute :id, Strict::String
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :type, Strict::String.optional

      def match(other)
        is_a?(other.class) && (id == other.id)
      end

      def identified_nodes
        super([id])
      end
    end
  end
end
