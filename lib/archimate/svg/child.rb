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
          entity = EntityFactory.make_entity(child, nil)
          if entity.nil?
            puts "Unable to make an SVG Entity for Child:\n#{child}"
          else
            entity.to_svg(xml)
          end
        end
        svg
      end

      def render_connections(svg)
        Nokogiri::XML::Builder.with(svg) do |xml|
          child.all_source_connections.each do |source_connection|
            conn = Connection.new(source_connection)
            if conn.nil?
              puts "Unable to make an SVG Connection for Source Connection:\n#{source_connection}"
            else
              conn.to_svg(xml)
            end
          end
        end
        svg
      end
    end
  end
end
