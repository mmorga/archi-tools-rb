# frozen_string_literal: true
module Archimate
  module DataModel
    module With
      using DiffablePrimitive
      using DiffableArray

      def with(options = {})
        self.class.new(
          to_h.keys.each_with_object({}) { |i, a| a[i] = send(i) }.merge(options)
        )
      end
    end
  end
end
