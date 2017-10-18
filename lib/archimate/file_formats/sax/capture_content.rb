# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module CaptureContent
        def characters(string)
          @content ||= []
          @content << string
          false
        end

        def content
          return nil unless defined?(@content)
          @content.join("")
        end
      end
    end
  end
end
