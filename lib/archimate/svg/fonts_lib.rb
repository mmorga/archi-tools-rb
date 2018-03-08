# frozen_string_literal: true

require "singleton"

module Archimate
  module Svg
    # This should be replaced with a portable alternative
    # I'm going to base this on fontconfig which should be fairly portable
    class FontsLib
      include Singleton

      DEFAULT_FONT_FACE = 'Lucida Grande'

      def path_to(font_face)
        cache.fetch(font_face&.strip || DEFAULT_FONT_FACE) { |face| lookup(face || DEFAULT_FONT_FACE) }
      end

      def lookup(font_face)
        fc_match = `fc-match "#{font_face}" file`
        file = fc_match.delete_prefix(":file=").strip
        cache[font_face] = file
        file
      end

      def cache
        @cache ||= {}
      end

      # DEFAULT_FONTS_CONF = '/usr/local/etc/fonts/fonts.conf'

      # def fonts_conf
      #   @fonts_conf ||= Nokogiri::XML(File.read(DEFAULT_FONTS_CONF))
      # end

      # def cache_dir
      #   @cache_dir ||= fonts_conf.at_css('cachedir').text
      # end

      # def font_cache
      #   @fonts_cache ||= Nokogiri::XML(File.read(cache_dir))
      # end
    end
  end
end
