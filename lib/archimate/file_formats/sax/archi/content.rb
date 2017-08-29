# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Content < FileFormats::Sax::Handler
          def initialize(name, attrs, parent_handler)
            super
            @characters = []
          end

          def complete
            content = @characters.join("").strip
            return [] if content.empty?
            [
              event(:on_content, content)
            ]
          end
        end
      end
    end
  end
end
