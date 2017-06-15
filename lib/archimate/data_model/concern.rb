# frozen_string_literal: true

module Archimate
  module DataModel
    # document attribute holds all the concern information.
    #
    # This is ConcernType in the XSD
    class Concern < ArchimateNode
      attribute :labels, Strict::Array.member(LangString).constrained(min_size: 1)
      attribute :documentation, DocumentationGroup
      attribute :stakeholders, Strict::Array.member(LangString)
    end

    Dry::Types.register_class(Concern)
    ConcernList = Strict::Array.member(Concern).default([])
  end
end
