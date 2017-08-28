# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      class Style < FileFormats::Sax::Handler
        def initialize(name, attrs, parent_handler)
          super
          @font = nil
          @text_position = nil
          @fill_color = nil
          @line_color = nil
          @font_color = nil
        end

        def complete
          style = DataModel::Style.new(
            text_alignment: attrs["textAlignment"],
            fill_color: @fill_color,
            line_color: @line_color,
            font_color: @font_color,
            font: @font,
            line_width: attrs["lineWidth"],
            text_position: @text_position # style.at_css("textPosition")
          )
          [
            event(:on_style, style)
          ]
        end

        def on_font(font, source)
          @font = font
          false
        end

        def on_fillColor(color, source)
          @fill_color = color
          false
        end

        def on_lineColor(color, source)
          @line_color = color
          false
        end

        def on_color(color, source)
          @font_color = color
          false
        end

        def on_textPosition(str, source)
          @text_position = str
          false
        end
      end
    end
  end
end
