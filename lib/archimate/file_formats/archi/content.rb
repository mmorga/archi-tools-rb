# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Content < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @characters = []
        end

        def complete
          content = @characters.join("").strip
          return [] if content.empty?
          [
            event(:on_content, content),
          ]
        end
      end
    end
  end
end
