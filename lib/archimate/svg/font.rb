# frozen_string_literal: true
module Archimate
  module Svg
    class Font
      attr_reader :draw

      def initialize
        @draw = Magick::Draw.new
        @draw.font = "/System/Library/Fonts/LucidaGrande.ttc"
        @draw.pointsize = 12
      end

      def text_width(text)
        draw.get_type_metrics(text).width
      end

      def fit_text_to_width(text, width)
        # t = Text.new
        results = []
        words = text.split(" ")
        candidate = words.shift
        until words.empty?
          next_word = words.shift
          new_candidate = candidate + " " + next_word
          # if t.width(new_candidate) > width
          if text_width(new_candidate) > width
            results << candidate
            candidate = next_word
          else
            candidate = new_candidate
          end
        end
        results << candidate
        results
      end
    end
  end
end
