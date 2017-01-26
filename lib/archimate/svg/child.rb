# frozen_string_literal: true
module Archimate
  module Svg
    class Child
      attr_reader :todos
      attr_reader :child

      def initialize(child, aio)
        @child = child
        @aio = aio
        @todos = Hash.new(0)
      end

      # The info needed to render is contained in the child with the exception of
      # any offset needed. So this will need to be included in the recursive drawing of children
      def render_elements(svg)
        Nokogiri::XML::Builder.with(svg) do |xml|
          Entity.new(child, nil).to_svg(xml)
        end
        svg
      end

      def render_connections(svg)
        Nokogiri::XML::Builder.with(svg) do |xml|
          child.all_source_connections.each do |source_connection|
            Connection.new(source_connection).to_svg(xml)
          end
        end
        svg
      end
    end
  end
end
