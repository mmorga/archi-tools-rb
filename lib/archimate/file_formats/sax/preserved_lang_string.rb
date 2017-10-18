# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      class PreservedLangString < FileFormats::Sax::Handler
        include Sax::CaptureContent

        def initialize(name, attrs, parent_handler)
          super
        end

        def complete
          doc = DataModel::PreservedLangString.string(
            process_text(content),
            @attrs["lang"] || @attrs["xml:lang"]
          )
          [
            event(
              :on_preserved_lang_string,
              doc
            )
          ]
        end
      end
    end
  end
end
