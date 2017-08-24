# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class PreservedLangString < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @characters_stack = []
        end

        def characters(string)
          @characters_stack.push(string)
        end

        def complete
          doc = DataModel::PreservedLangString.string(
                process_text(@characters_stack.join("")),
                @attrs["lang"]
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
