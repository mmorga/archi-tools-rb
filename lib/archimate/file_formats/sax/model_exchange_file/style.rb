# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class Style < FileFormats::Sax::Handler
          def initialize(name, attrs, parent_handler)
            super
            @font = nil
            @text_position = nil
            @fill_color = nil
            @line_color = nil
            @font_color = nil
            @style = nil
          end

          def complete
            [
              event(:on_style, style)
            ]
          end

          def on_font(font, _source)
            @font = font
            false
          end

          def on_fill_color(color, _source)
            @fill_color = color
            false
          end

          def on_line_color(color, _source)
            @line_color = color
            false
          end

          def on_color(color, _source)
            @font_color = color
            false
          end

          def on_text_position(str, _source)
            @text_position = str
            false
          end

          private

          def style
            @style ||= DataModel::Style.new(
              text_alignment: attrs["textAlignment"],
              fill_color: @fill_color,
              line_color: @line_color,
              font_color: @font_color,
              font: @font,
              line_width: attrs["lineWidth"],
              text_position: @text_position
            )
          end
        end
      end
    end
  end
end
