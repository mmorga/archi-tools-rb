# frozen_string_literal: true

module Archimate
  module DataModel
    class Metadata < ArchimateNode
      using DiffablePrimitive

      attribute :elements, Strict::Array.member(SchemaInfo).default([])

      def to_s
        "#{type.light_black}[#{data.map(&:to_s).join(', ')}]"
      end
    end
    Dry::Types.register_class(Metadata)
  end
end
