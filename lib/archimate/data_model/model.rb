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
      attribute :elements, Strict::Hash
      attribute :folders, Strict::Hash
      attribute :relationships, Strict::Hash
      attribute :diagrams, Strict::Hash

      def self.create(options = {})
        new_opts = {
          parent_id: nil,
          documentation: [],
          properties: [],
          elements: {},
          folders: {},
          relationships: {},
          diagrams: {}
        }.merge(options)
        Model.new(new_opts)
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
          elements: elements.each_with_object({}) { |(k, v), a| a[k] = v.clone },
          folders: folders.each_with_object({}) { |(k, v), a| a[k] = v.clone },
          relationships: relationships.each_with_object({}) { |(k, v), a| a[k] = v.clone },
          diagrams: diagrams.each_with_object({}) { |(k, v), a| a[k] = v.clone }
        )
      end

      def describe(item, options = {})
        case item
        when Model
          "#{'Model'.cyan.italic}[#{name.white.underline}]"
        when Dry::Struct
          item.describe(self)
        else
          item.to_s
        end
      end

      # returns a copy of self with element added
      # (or replaced with) the given element
      def insert_element(element)
        with(
          elements:
            elements.merge(element.id => element)
        )
      end

      # returns a copy of self with relationship added
      # (or replaced with) the given relationship
      def insert_relationship(relationship)
        with(
          relationships:
            relationships.merge(relationship.id => relationship)
        )
      end

      def find_folder(folder_id)
        Folder.find_in_folders(folders, folder_id)
      end

      # TODO: consider refactoring all of the ref/unref methods to another class
      def ref_set
        Set.new(relationship_element_references + diagram_element_references)
      end

      def relationship_element_references
        relationships.map(&:element_references).flatten.uniq
      end

      def diagram_element_references
        diagrams.values.map(&:element_references).flatten.compact.uniq
      end

      def unref_set
        model_set - ref_set
      end

      def unrefed_ids
        unref_set + (relation_ids - relation_ref_ids)
      end
    end
  end
end
