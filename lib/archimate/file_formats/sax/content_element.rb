# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      class ContentElement < Handler
        include Sax::CaptureContent

        def initialize(name, attrs, parent_handler)
          super
        end

        def complete
          [event("on_#{@name}".to_sym, content)]
        end
      end
    end
  end
end
