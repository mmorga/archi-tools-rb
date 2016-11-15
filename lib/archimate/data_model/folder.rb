# frozen_string_literal: true
module Archimate
  module DataModel
    # The Folder class represents a folder that contains elements, relationships,
    # and diagrams. In the Archimate standard file export model exchange format,
    # this is representated as items. In the Archi file format, this is
    # represented as folders.
    class Folder < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :id, Strict::String
      attribute :name, Strict::String
      attribute :type, Strict::String.optional
      attribute :items, Strict::Array.member(Strict::String)
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :folders, Strict::Array.member(Folder)

      def self.create(options = {})
        new_opts = {
          type: nil,
          items: [],
          documentation: [],
          properties: [],
          folders: []
        }.merge(options)
        Folder.new(new_opts)
      end

      def comparison_attributes
        [:@id, :@name, :@type, :@items, :@documentation, :@properties, :@folders]
      end

      def clone
        Folder.new(
          parent_id: parent_id&.clone,
          id: id.clone,
          name: name.clone,
          type: type&.clone,
          items: items.map(&:clone),
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          folders: folders.map(&:clone)
        )
      end

      def self.find_in_folders(folders, folder_id)
        folder = folders.find { |i| i.id == folder_id }
        return folder unless folder.nil?

        folders.each do |f|
          folder = find_in_folders(f.folders, folder_id)
          return folder unless folder.nil?
        end
        nil
      end

      def find_folder(folder_id)
        return self if id == folder_id
        folders.each do |f|
          found_folder = f.find_folder(folder_id)
          return found_folder unless found_folder.nil?
        end
        nil
      end

      def to_s
        "#{'Folder'.cyan}<#{id}>[#{name.white.underline}]"
      end
    end
    Dry::Types.register_class(Folder)
  end
end
