# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module Style
          def serialize_style(xml, style)
            return unless style
            xml.style(
              remove_nil_values(
                lineWidth: style.line_width
              )
            ) do
              serialize_color(xml, style.fill_color, :fillColor)
              serialize_color(xml, style.line_color, :lineColor)
              serialize_font(xml, style)
              # TODO: complete this
            end
          end

          def serialize_font(xml, style)
            return unless style && (style.font || style.font_color)
            xml.font(
              remove_nil_values(
                name: style.font&.name,
                size: style.font&.size&.round,
                style: font_style_string(style.font)
              )
            ) { serialize_color(xml, style&.font_color, :color) }
          end

          def serialize_color(xml, color, sym)
            return if color.nil?
            h = {
              r: color.r,
              g: color.g,
              b: color.b,
              a: color.a
            }
            h.delete(:a) if color.a.nil? || color.a == 100
            xml.send(sym, h)
          end
        end
      end
    end
  end
end
