# frozen_string_literal: true
module Archimate
  module DataModel
    class IdentifiedNode < ArchimateNode
      attribute :id, Strict::String
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :type, Strict::String.optional

      private

      def find_my_index
        id
      end
    end
  end
end
