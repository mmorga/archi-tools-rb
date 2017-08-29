# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      module CaptureProperties
        def on_property(property, _source)
          @properties ||= []
          @properties << property
          false
        end

        def properties
          return [] unless defined?(@properties)
          @properties || []
        end
      end
    end
  end
end
