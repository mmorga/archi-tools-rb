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

        def label
          entity.name || child.content
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

        # TODO: This should be overridden where necessary for specialty cases
        # where the content would be shown differently (like for notes)
        def entity_label(xml)
          badge_bounds = badge ? DataModel::Bounds.new(x: 0, y: 0, width: 20, height: 20) : DataModel::Bounds.zero
          Svg::EntityLabel.new(child, label, text_bounds, @text_align, badge_bounds).to_svg(xml)
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
