# frozen_string_literal: true
require "set"

module Archimate
  module DataModel
    class Model < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String.optional
      attribute :id, Strict::String
      attribute :name, Strict::String
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :elements, Strict::Array.member(Element)
      attribute :folders, Strict::Array.member(Folder)
      attribute :relationships, Strict::Array.member(Relationship)
      attribute :diagrams, Strict::Array.member(Diagram)

      def self.create(options = {})
        new_opts = {
          parent_id: nil,
          documentation: [],
          properties: [],
          elements: [],
          folders: [],
          relationships: [],
          diagrams: []
        }.merge(options)
        Model.new(new_opts)
      end

      def self.flat_folder_hash(folders, h = {})
        folders.each_with_object(h) do |folder, a|
          a[folder.id] = folder
          a.merge!(flat_folder_hash(folder.folders))
        end
      end

      def initialize(attributes)
        super
        assign_model(self)
      end

      def lookup(id)
        @index_hash ||= elements.each_with_object(id => self) { |i, a| a[i.id] = i }.merge(
          relationships.each_with_object({}) { |i, a| a[i.id] = i }.merge(
            diagrams.each_with_object(Model.flat_folder_hash(folders)) { |i, a| a[i.id] = i }
          )
        )

        @index_hash[id]
      end

      def comparison_attributes
        [:@id, :@name, :@documentation, :@properties, :@elements, :@folders, :@relationships, :@diagrams]
      end

      def clone
        Model.new(
          parent_id: parent_id&.clone,
          id: id.clone,
          name: name.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          elements: elements.map(&:clone),
          folders: folders.map(&:clone),
          relationships: relationships.map(&:clone),
          diagrams: diagrams.map(&:clone)
        )
      end

      def to_s
        "#{'Model'.cyan}<#{id}>[#{name.white.underline}]"
      end

      # returns a copy of self with element added
      # (or replaced with) the given element
      def insert_element(element)
        new_elements = elements.map { |e| e.id == element.id ? element : e }
        new_elements.push(element) unless new_elements.include?(element)
        with(
          elements: new_elements
        )
      end

      # returns a copy of self with relationship added
      # (or replaced with) the given relationship
      def insert_relationship(relationship)
        new_relationships = relationships.map { |r| r.id == relationship.id ? relationship : r }
        new_relationships.push(relationship) unless new_relationships.include?(relationship)
        with(
          relationships: new_relationships
        )
      end

      def find_folder(folder_id)
        folders.each do |f|
          found_folder = f.find_folder(folder_id)
          return found_folder unless found_folder.nil?
        end
        nil
      end
    end
  end
end
