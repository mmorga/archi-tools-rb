# frozen_string_literal: true
module Archimate
  module DataModel
    class Font < Dry::Struct::Value
      attribute :name, Strict::String
      attribute :size, Coercible::Int
      attribute :style, Strict::String.optional
    end

    Dry::Types.register_class(Font)
    OptionalFont = Font.optional
  end
end
