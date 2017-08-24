# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      module CaptureDocumentation
        def on_preserved_lang_string(documentation, source)
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
