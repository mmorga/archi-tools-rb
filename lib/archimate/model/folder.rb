# frozen_string_literal: true
module Archimate
  module Model
    # The Folder class represents a folder that contains elements, relationships,
    # and diagrams. In the Archimate standard file export model exchange format,
    # this is representated as items. In the Archi file format, this is
    # represented as folders.
    class Folder < Dry::Struct::Value
      attribute :id, Archimate::Model::Strict::String
      attribute :name, Archimate::Model::Strict::String
      attribute :type, Archimate::Model::Strict::String.optional
      attribute :items, Archimate::Model::ElementIdList
      attribute :documentation, Archimate::Model::DocumentationList
      attribute :properties, Archimate::Model::PropertiesList
      attribute :folders, Archimate::Model::FolderHash

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
