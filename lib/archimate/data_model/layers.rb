# frozen_string_literal: true

require "ruby-enum"

module Archimate
  module DataModel
    class Layers
      include Ruby::Enum

      define :Strategy, Layer.new(
        "Strategy",
        "archimate-strategy-background"
      )

      define :Business, Layer.new(
        "Business",
        "archimate-business-background"
      )

      define :Application, Layer.new(
        "Application",
        "archimate-application-background"
      )

      define :Technology, Layer.new(
        "Technology",
        "archimate-infrastructure-background"
      )

      define :Physical, Layer.new(
        "Physical",
        "archimate-physical-background"
      )

      define :Motivation, Layer.new(
        "Motivation",
        "archimate-motivation-background"
      )

      define :Implementation_and_migration, Layer.new(
        "Implementation and Migration",
        "archimate-implementation-background"
      )

      define :Connectors, Layer.new(
        "Connectors",
        "archimate-connectors-background"
      )

      define :Other, Layer.new(
        "Other",
        "archimate-other-background"
      )

      define :None, Layer.new("None")
    end
  end
end
