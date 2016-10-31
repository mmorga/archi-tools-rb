# frozen_string_literal: true
module Archimate
  module DataModel
    class Font < Dry::Struct
      attribute :name, Strict::String
      attribute :size, Coercible::Int.constrained(gt: 0)
      attribute :style, Strict::String.optional

      def clone
        Font.new(
          name: name.clone,
          size: size,
          style: style.nil? ? nil : style.clone
        )
      end

      def describe(_model)
        "Font(name: #{name}, size: #{size}, style: #{style})"
      end
    end

    Dry::Types.register_class(Font)
    OptionalFont = Font.optional
  end
end
