# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      class NoOp < Handler
        def initialize(name, attrs, parent_handler)
          super
        end

        def complete
          []
        end
      end
    end
  end
end
