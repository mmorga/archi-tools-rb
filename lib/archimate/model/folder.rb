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
        @folders = []
        yield self if block_given?
      end
    end
  end
end
