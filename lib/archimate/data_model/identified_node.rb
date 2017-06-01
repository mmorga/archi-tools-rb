# frozen_string_literal: true
module Archimate
  module DataModel
    class IdentifiedNode < ArchimateNode
      attribute :id, Strict::String
      attribute :name, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :type, Strict::String.optional

      private

      def find_my_index
        id
      end

      # name isn't merged
      def merge(node)
        documentation.concat(node.documentation)
        properties.concat(node.properties)
      end
    end
  end
end
