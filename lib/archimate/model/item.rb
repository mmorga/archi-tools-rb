module Archimate
  module Model
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
