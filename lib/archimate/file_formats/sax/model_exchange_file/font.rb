# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
    module ModelExchangeFile
      class Font < FileFormats::Sax::Handler
        def initialize(name, attrs, parent_handler)
          super
        end

        def complete
          font = DataModel::Font.new(
            name: attrs["name"],
            size: attrs["size"],
            style: style_to_int(attrs["style"]),
            font_data: nil
          )
          [
            event(:on_font, font)
          ]
        end

        def style_to_int(str)
          case str
          when nil
            0
          when "italic"
            1
          when "bold"
            2
          when "bold|italic", "bold italic"
            3
          else
            raise "Broken for value: #{str}"
          end
        end
      end
    end
    end
  end
end
