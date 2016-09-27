# frozen_string_literal: true
module Archimate
  module Model
    # The Folder class represents a folder that contains elements, relationships,
    # and diagrams. In the Archimate standard file export model exchange format,
    # this is representated as items. In the Archi file format, this is
    # represented as folders.
    class Folder < Dry::Struct::Value
      attribute :id, Types::Strict::String
      attribute :name, Types::Strict::String
      attribute :type, Types::Strict::String.optional
      attribute :items, Types::ElementIdList
      attribute :documentation, Types::DocumentationList
      attribute :properties, Types::PropertiesList
      attribute :folders, Types::FolderHash

      def self.create(options = {})
        new_opts = {
          type: nil,
          items: [],
          documentation: [],
          properties: [],
          folders: {}
        }.merge(options)
        Folder.new(new_opts)
      end

      def with(options = {})
        Folder.new(to_h.merge(options))
      end
    end
  end
end
