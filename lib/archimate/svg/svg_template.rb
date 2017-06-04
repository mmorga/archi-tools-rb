# frozen_string_literal: true

require "erb"

module Archimate
  module Svg
    class SvgTemplate
      attr_reader :stylesheet

      def initialize
        @stylesheet = css_content
      end

      def css_content
        @css_content ||= File.read(File.join(File.dirname(__FILE__), "archimate.css"))
      end

      def svg_erb
        @svg_erb ||= File.read(File.join(File.dirname(__FILE__), "svg_template.svg.erb"))
      end

      def to_s
        @template_xml ||= ERB.new(svg_erb).result(binding)
      end
    end
  end
end
