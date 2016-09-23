# frozen_string_literal: true
module Archimate
  module Model
    # The Folder class represents a folder that contains elements, relationships,
    # and diagrams. In the Archimate standard file export model exchange format,
    # this is representated as items. In the Archi file format, this is
    # represented as folders.
    class Folder < Dry::Struct::Value
      attribute :id, Archimate::Types::Strict::String
      attribute :name, Archimate::Types::Strict::String
      attribute :type, Archimate::Types::String
      attribute :items, Archimate::Types::Strict::Array.member(Archimate::Types::Strict::String)
      attribute :documentation, Archimate::Types::Strict::Array.member(Archimate::Types::Strict::String)
      attribute :properties, Archimate::Types::Strict::Array.member(Archimate::Types::Strict::String)
      attribute :folders, Archimate::Types::Coercible::Hash

      def self.create(id:, name:, type: nil)
        Folder.new(
          id: id,
          name: name,
          type: type,
          items: [],
          documentation: [],
          properties: [],
          folders: {}
        )
      end

      def with(options = {})
        Folder.new(to_h.merge(options))
      end
    end
  end
end
