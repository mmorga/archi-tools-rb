# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      class Handler
        attr_reader :name
        attr_reader :attrs
        attr_reader :parent_handler
        attr_reader :element_type

        def initialize(name, attrs, parent_handler)
          @name = name
          @attrs = Hash[attrs]
          @parent_handler = parent_handler
          @element_type = @attrs["xsi:type"]&.sub(/archimate:/, '')
        end

        def characters(string); end

        # @return [Array<Event>] array of events to fire for this handler
        def complete
          []
        end

        def diagram
          parent_handler&.diagram
        end

        def event(sym, args)
          SaxEvent.new(sym, args, self)
        end

        def method_missing(sym, *args)
          return args.first if sym.to_s.start_with?("on_")
          super
        end

        def respond_to_missing?(symbol, _include_all)
          symbol.to_s.start_with?("on_")
        end

        # Returns the property definitions hash for this SaxDocument
        def property_definitions
          parent_handler&.property_definitions || []
        end

        def process_text(str)
          str&.gsub("&#38;", "&")
        end
      end
    end
  end
end
