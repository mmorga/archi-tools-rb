# frozen_string_literal: true

module Archimate
  module Svg
    class Connection
      attr_reader :connection
      attr_reader :css_style

      def initialize(connection)
        @connection = connection
        @path = Path.new(@connection)
        @css_style = CssStyle.new(connection.style)
      end

      def render(svg)
        Nokogiri::XML::Builder.with(svg) do |xml|
          to_svg(xml)
        end
        svg
      end

      def to_svg(xml)
        return if connection.source.nodes.include?(connection.target)
        xml.path(path_attrs) do
          xml.title @connection.description
        end

        name = connection&.relationship&.name&.strip
        return if name.nil? || name.empty?
        pt = @path.point(text_position)
        xml.text_(
          class: "archimate-relationship-name",
          x: pt.x,
          y: pt.y,
          "text-anchor" => "middle",
          style: css_style.text
        ) do
          xml.text name
        end
      end

      def line_style
        style = connection.style
        return "" if style.nil?
        {
          "stroke": style.line_color&.to_rgba,
          "stroke-width": style.line_width
        }.delete_if { |_key, value| value.nil? }
          .map { |key, value| "#{key}:#{value};" }
          .join("")
      end

      def text_position
        case connection.style&.text_position
        when 0
          0.1 # "10%"
        when 1
          0.9 # "90%"
        else
          0.5 # "50%"
        end
      end

      def path_attrs
        {
          id: id,
          class: path_class,
          d: @path.d,
          style: line_style
        }
      end

      def id
        connection.relationship&.id || connection.id
      end

      # Look at the type (if any of the path and set the class appropriately)
      def path_class
        [
          "archimate",
          css_classify(connection&.relationship&.type || "default")
        ].join("-") + " archimate-relationship"
      end

      # TODO: StringRefinements refinement isn't working in this class, so added this method here. Investigate.
      def css_classify(str)
        str.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2')
           .gsub(/([a-z\d])([A-Z])/, '\1-\2')
           .downcase
      end
    end
  end
end
