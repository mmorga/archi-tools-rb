# frozen_string_literal: true

module Archimate
  module Svg
    # **StereotypeLabel** < **Label**
    #
    # Split out any stereotype portion to render separately
    #
    # * Replace angle bracket characters with &laquo; and &raquo;
    # * Apply stereotype styling
    # * Position stereotype line as below
    # * Adjust Label start position (move down line height for remaining label
    #
    # Take remaining text
    #
    # **Label**
    #
    # * ctor:
    #     - rect to contain label
    #     - text
    #     - style
    # * Figure out line breaks based on **Text** length
    # * Render each line (that fits in the rect) in an SVG `text` element
    class EntityLabel
      attr_reader :child
      attr_reader :label
      attr_reader :text_anchor
      attr_reader :text_bounds
      attr_reader :badge_bounds

      def initialize(child, label, text_bounds, text_align, badge_bounds)
        @child = child
        @label = label
        @text_bounds = text_bounds
        @badge_bounds = badge_bounds
        @text_align = text_align
        @text_anchor = case text_align
                       when "left"
                         "start"
                       when "right"
                         "end"
                       else
                         "middle"
                       end
      end

      def to_svg(xml)
        # return if (entity.nil? || entity.name.nil? || entity.name.strip.empty?) && (child.content.nil? || child.content.strip.empty?)
        return unless label && !label.empty?
        # TODO: What's the general shape here? Do I need to put the text into a group that clips?
        text_styles.reduce(text_bounds.top) do |y, (str, length, line_height, text_class)|
          return if y + line_height > text_bounds.bottom
          xml.text_(
            x: line_x,
            y: y + line_height,
            textLength: length,
            lengthAdjust: "spacingAndGlyphs",
            class: text_class,
            style: text_style,
            "text-anchor" => text_anchor
          ) do
            xml.text(str)
          end
          # xml.polygon(
          #   points: polygon_path,
          #   style: "stroke: red; stroke-width: 1px; stroke-dasharray: 3,3; fill: none;"
          # )
          y + line_height
        end
      end

      def polygon_path
        [
          [text_bounds.left, text_bounds.top],
          [text_bounds.right - badge_bounds.width, text_bounds.top],
          [text_bounds.right - badge_bounds.width, text_bounds.top + badge_bounds.height],
          [text_bounds.right, text_bounds.top + badge_bounds.height],
          [text_bounds.right, text_bounds.bottom],
          [text_bounds.left, text_bounds.bottom]
        ].uniq.map { |x, y| "#{x},#{y}" }.join(" ")
      end

      def line_x
        case text_anchor
        when "start"
          text_bounds.left
        when "end"
          text_bounds.right - badge_bounds.width
        else
          text_bounds.center.x - (badge_bounds.width / 2.0)
        end
      end

      # Splits the text of the entity by newlines and to fit space available
      def text_styles
        text_lines.each_with_object([]) do |line, lines|
          text = Text.new(line, child.style)
          lines.concat(
            text.layout_with_max(max_widths)
                .map { |str, len| [str, len, text.line_height, "entity-name"] }
          )
        end
      end

      def max_widths
        line_height = Text.new("", child.style).line_height
        rows = text_bounds.height / line_height
        (0..rows).map do |i|
          if i * line_height < badge_bounds.height
            text_bounds.width - badge_bounds.width
          else
            text_bounds.width
          end
        end
      end

      def text_lines
        label.tr("\r\n", "\n").split(/[\r\n]/)
        # (entity.name || child.content).tr("\r\n", "\n").lines
      end

      def text_style
        style = child.style || DataModel::Style.new
        {
          "fill": style.font_color&.to_rgba,
          "color": style.font_color&.to_rgba,
          "font-family": style.font&.name,
          "font-size": style.font&.size,
          "text-align": style.text_align || @text_align
        }.delete_if { |_key, value| value.nil? }
          .map { |key, value| "#{key}:#{value};" }
          .join("")
      end
    end
  end
end
