# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Documentation < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @characters_stack = []
        end

        def characters(string)
          @characters_stack.push(string)
        end

        def complete
          [
            event(
              :on_documentation,
              DataModel::PreservedLangString.string(
                @characters_stack.join(""),
                @attrs["lang"]
              )
            )
          ]
        end
      end
    end
  end
end
