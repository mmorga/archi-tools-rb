# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      class XmlLangString
        def initialize(lang_str, tag_name)
          @tag_name = tag_name
          @lang_strs = Array(lang_str)
        end

        def serialize(xml)
          return if @lang_strs.empty?

          @lang_strs.each do |lang_str|
            attrs = lang_str.lang && !lang_str.lang.empty? ? {"xml:lang" => lang_str.lang} : {}
            xml.send(@tag_name, attrs) { xml.text text_proc(lang_str) }
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
