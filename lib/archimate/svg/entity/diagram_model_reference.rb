# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class DiagramModelReference < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-diagram-model-reference-badge"
          @background_class = "archimate-diagram-model-reference-background"
          @entity = child.model_element
        end

        def optional_link(xml, &block)
          xml.a(href: "#{@entity.id}.svg") do
            block.call
          end
        end
      end
    end
  end
end
