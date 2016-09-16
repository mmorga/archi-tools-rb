module Archimate
  module Model
    # The Item class represents a folder that contains elements, relationships,
    # and diagrams. In the Archimate standard file export model exchange format,
    # this is representated as items. In the Archi file format, this is
    # represented as folders.
    class Item
      attr_reader :identifier_ref, :label, :documentation, :items

      def initialize(identifier_ref = nil, label = nil, documentation = nil, items = [])
        @identifier_ref = identifier_ref
        @label = label
        @documentation = documentation
        @items = items
      end
    end
  end
end
