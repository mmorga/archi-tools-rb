# frozen_string_literal: true
require "ruby-enum"

module Archimate
  module DataModel
    class ConnectorType
      include Ruby::Enum

      define :AndJunction, "AndJunction"
      define :Junction, "Junction"
      define :OrJunction, "OrJunction"

      def self.===(other)
        values.include?(other)
      end
    end
  end
end
