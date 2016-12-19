# frozen_string_literal: true
module Archimate
  module DataModel
    class Style < NonIdentifiedNode
      attribute :text_alignment, Coercible::Int.optional # TODO: make this an enum
      attribute :fill_color, Color.optional
      attribute :line_color, Color.optional
      attribute :font_color, Color.optional # TODO: move this to font
      attribute :line_width, Coercible::Int.optional
      attribute :font, Font.optional
      attribute :text_position, Coercible::Int.optional # TODO: make this an enum

      def to_s
        attr_name_vals = struct_instance_variables.map { |k| "#{k}: #{self[k]}" }.join(", ")
        "Style(#{attr_name_vals})"
      end
    end

    Dry::Types.register_class(Style)
  end
end
