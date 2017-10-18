# frozen_string_literal: true

require "nokogiri"

module Archimate
  module FileFormats
    module Sax
      # SaxStack implements a stack like processor to maintain context
      # during SAX processing of XML documents. It provides the means
      # for a handler for a SAX event to raise events to handlers
      # further up the stack and to query ancestor handlers.
      class Document < Nokogiri::XML::SAX::Document
        attr_reader :model
        attr_reader :handler_factory

        def initialize(handler_factory)
          super()
          @handler_factory = handler_factory
          @stack = []
          @model = nil
        end

        # Document is done.
        # def end_document
        # @model = @sax_stack.model
        # end

        # Push a handler onto the stack.
        #
        # create an instance of the correct builder for this element
        # push it onto the @stack
        #
        # Note: {#unshift} is used here rather than {#push} in the
        # underlying implementation because I want events to flow from
        # last-in to first-in when they are fired and this lets be use
        # {#take_while} without reversing the stack array.
        #
        # @param obj [SaxHandler] Handler to push on the stack
        def start_element(name, attrs = [])
          cls = handler_factory.handler_for(name, attrs)
          @stack.unshift(
            cls.new(name, attrs, @stack.first)
          )
        end

        # Handler is completed. Fires any of the handlers events
        # and pops the handler off of the stack.
        #
        # See {#push} regarding why {#shift} is used instead of {#pop}
        def end_element(_name)
          fire(@stack.shift.complete)
        end

        def current_handler
          @stack.first
        end

        def characters(string)
          current_handler.characters(string)
        end

        # Fire an event up the stack. Events are received at each handler
        # until a handler returns nil or false.
        #
        # @param events [Array<SaxEvent>] zero or more Events to bubble up the stack
        def fire(events)
          Array(events).each do |event|
            if event.sym == :on_model
              @model = event.args
            else
              @stack.take_while do |target|
                target.send(event.sym, event.args, event.source)
              end
            end
          end
        end
      end
    end
  end
end
