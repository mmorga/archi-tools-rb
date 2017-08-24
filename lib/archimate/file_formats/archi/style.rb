# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      module Style
        def style
          style_hash = {
            text_alignment: attrs["textAlignment"],
            fill_color: DataModel::Color.rgba(attrs["fillColor"]),
            line_color: DataModel::Color.rgba(attrs["lineColor"]),
            font_color: DataModel::Color.rgba(attrs["fontColor"]),
            font: DataModel::Font.archi_font_string(attrs["font"]),
            line_width: attrs["lineWidth"],
            text_position: attrs["textPosition"]
          }.delete_if { |_k, v| v.nil? }
          return nil if style_hash.empty?
          DataModel::Style.new(style_hash)
        end
      end
    end
  end
end
