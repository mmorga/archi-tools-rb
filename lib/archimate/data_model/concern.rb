# frozen_string_literal: true

module Archimate
  module DataModel
    # document attribute holds all the concern information.
    class Concern < ArchimateNode
      attribute :labels, LabelGroup # .constrained(min_size: 1)
      attribute :documentation, DocumentationGroup
      attribute :stakeholders, Stakeholders
    end

    Dry::Types.register_class(Concern)
    ConcernList = Strict::Array.member(Concern).default([])
  end
end
