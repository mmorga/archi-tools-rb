module Archimate
  module Model
    class Organization
      attr_reader :items

      def initialize(items)
        @items = items
      end
    end
  end
end
