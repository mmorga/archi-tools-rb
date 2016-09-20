# frozen_string_literal: true
module Archimate
  module Model
    # The Folder class represents a folder that contains elements, relationships,
    # and diagrams. In the Archimate standard file export model exchange format,
    # this is representated as items. In the Archi file format, this is
    # represented as folders.
    class Folder
      attr_reader :id, :name, :type
      attr_accessor :items, :folders, :documentation, :properties

      def initialize(id, name, type = nil)
        @id = id
        @name = name
        @type = type
        @documentation = []
        @properties = []
        @items = []
        @folders = {}
        yield self if block_given?
      end

      def ==(other)
        @id == other.id &&
          @name == other.name &&
          @type == other.type &&
          @documentation == other.documentation &&
          @properties == other.properties &&
          @items == other.items &&
          @folders == other.folders
      end

      def hash
        self.class.hash ^
          @id.hash ^
          @name.hash ^
          @type.hash ^
          @documentation.hash ^
          @properties.hash ^
          @items.hash ^
          @folders.hash
      end

      def dup(id: nil, name: nil, type: nil)
        Folder.new(id || @id, name || @name, type || @type) do |copy|
          copy.items = Array.new(items)
          copy.folders = folders.dup
          copy.documentation = Array.new(documentation)
          copy.properties = Array.new(properties)
        end
      end

      def add_folder(f)
        @folders[f.id] = f
      end
    end
  end
end
