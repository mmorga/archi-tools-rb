# frozen_string_literal: true

module Archimate
  module Svg
    class ViewNode
      attr_reader :view_node

      def initialize(view_node)
        @view_node = view_node
      end

      # The info needed to render is contained in the view node with the exception of
      # any offset needed. So this will need to be included in the recursive drawing of children
      def render_elements(svg)
        Nokogiri::XML::Builder.with(svg) do |xml|
          EntityFactory.make_entity(view_node, nil).to_svg(xml)
        end
        svg
      end
    end
  end
end
