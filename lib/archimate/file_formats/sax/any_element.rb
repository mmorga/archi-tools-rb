# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      class AnyElement < Handler
        include Sax::CaptureContent

        def initialize(name, attrs, parent_handler)
          super
          @children = []
          @el_name = nil
          @prefix = nil
        end

        def complete
          [event(
            :on_any_element,
            DataModel::AnyElement.new(
              element: el_name,
              prefix: prefix,
              attributes: any_attributes,
              content: content,
              children: @children
            )
          )]
        end

        def on_any_element(any_element, _source)
          @children << any_element
          false
        end

        private

        def el_name
          parse_name unless @el_name
          @el_name
        end

        def prefix
          parse_name unless @el_name
          @prefix
        end

        def parse_name
          name_parts = name.split(":")
          @prefix = name_parts.size > 1 ? name_parts.first : nil
          @el_name = name_parts.last
        end

        def any_attributes
          attrs.map do |attr_name, attr_val|
            DataModel::AnyAttribute.new(
              attr_name,
              attr_val,
              prefix: attr_name.split(":").first
            )
          end
        end
      end
    end
  end
end
