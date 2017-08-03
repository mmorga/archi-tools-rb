# frozen_string_literal: true

module Archimate
  module DataModel
    # document attribute holds all the concern information.
    #
    # This is ConcernType in the XSD
    class Concern < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :labels, Strict::Array.member(LangString).constrained(min_size: 1)
      attribute :documentation, PreservedLangString
      attribute :stakeholders, Strict::Array.member(LangString)
    end

    Dry::Types.register_class(Concern)
  end
end
