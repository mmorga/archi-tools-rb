# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class BaseEntity
        attr_reader :child
        attr_reader :entity
        attr_reader :bounds_offset
        attr_reader :text_bounds
        attr_reader :badge_bounds
        attr_reader :badge
        attr_reader :background_class

        def initialize(child, bounds_offset)
          @child = child
          @text_bounds = child.bounds.reduced_by(2)
          @bounds_offset = bounds_offset
          @entity = @child.element || @child
          @background_class = @child&.element&.layer&.background_class
          @text_align = nil
          @badge = nil
        end

        def to_svg(xml)
          optional_link(xml) do
            xml.g(group_attrs) do
              xml.title { xml.text @entity.name } unless @entity.name.nil? || @entity.name.empty?
              xml.desc { xml.text(@entity.documentation.to_s) } unless @entity.documentation&.empty?
              entity_shape(xml, child.bounds)
              entity_badge(xml)
              entity_label(xml)
              child.nodes.each { |c| Svg::EntityFactory.make_entity(c, child.bounds).to_svg(xml) }
            end
          end
        end

        def optional_link(_xml)
          yield
        end

        def entity_label(xml)
          return if (entity.nil? || entity.name.nil? || entity.name.strip.empty?) && (child.content.nil? || child.content.strip.empty?)
          xml.foreignObject(text_bounds.to_h) do
            xml.table(xmlns: "http://www.w3.org/1999/xhtml", style: "height:#{text_bounds.height}px;width:#{text_bounds.width}px;") do
              xml.tr(style: "height:#{text_bounds.height}px;") do
                xml.td(class: "entity-name") do
                  xml.div(class: "archimate-badge-spacer") unless badge.nil?
                  xml.p(class: "entity-name", style: text_style) do
                    text_lines(entity.name || child.content).each do |line|
                      xml.text(line)
                      xml.br
                    end
                  end
                end
              end
            end
          end
        end

        def text_lines(text)
          text.tr("\r\n", "\n").split(/[\r\n]/)
        end

        def entity_badge(xml)
          return if badge.nil?
          xml.use(
            badge_bounds
              .to_h
              .merge("xlink:href" => badge)
          )
        end

        def shape_style
          style = child.style
          return "" if style.nil?
          {
            "fill": style.fill_color&.to_rgba,
            "stroke": style.line_color&.to_rgba,
            "stroke-width": style.line_width
          }.delete_if { |_key, value| value.nil? }
            .map { |key, value| "#{key}:#{value};" }
            .join("")
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

        def group_attrs
          attrs = { id: @entity.id }
          # TODO: Transform only needed only for Archi file types
          attrs[:transform] = "translate(#{@bounds_offset.x || 0}, #{@bounds_offset.y || 0})" unless @bounds_offset.nil?
          attrs[:class] = "archimate-#{@entity.type}" if @entity.type || !@entity.type.empty?
          attrs
        end
      end
    end
  end
end
