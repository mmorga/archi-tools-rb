# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      class XmlLangString
        def initialize(lang_str, tag_name)
          @tag_name = tag_name
          @lang_str = lang_str
        end

        def serialize(xml)
          return unless @lang_str && !@lang_str.empty?

          @lang_str.langs.each do |lang|
            attrs = lang && !lang.empty? ? { "xml:lang" => lang } : {}
            xml.send(@tag_name, attrs) { xml.text text_proc(@lang_str.by_lang(lang)) }
          end
        end

        # Processes text for text elements
        private

        def text_proc(str)
          str.strip.tr("\r", "\n")
        end
      end
    end
  end
end
