# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module CaptureDocumentation
        def on_preserved_lang_string(documentation, _source)
          @documentation = documentation
          false
        end

        def documentation
          return nil unless defined?(@documentation)
          @documentation
        end
      end
    end
  end
end
