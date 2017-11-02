# frozen_string_literal: true

require "ruby-enum"

module Archimate
  module DataModel
    # An enumeration of the connector types available in Archimate
    # @example Reference an "And" Junction.
    #   ConnectorType::AndJunction #=> "AndJunction"
    class ConnectorType
      include Ruby::Enum

      define :AndJunction, "AndJunction"
      define :Junction, "Junction"
      define :OrJunction, "OrJunction"

      # Returns true if {other} is a +ConnectorType+
      # @param other [String]
      def self.===(other)
        values.include?(other)
      end
    end
  end
end
