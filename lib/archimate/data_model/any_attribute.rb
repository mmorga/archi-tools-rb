# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of any XML attribute for arbitrary content like metadata
    class AnyAttribute < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :attribute, Strict::String
      attribute :prefix, Strict::String
      attribute :value, Strict::String
    end
    Dry::Types.register_class(AnyAttribute)
  end
end
