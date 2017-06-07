# frozen_string_literal: true

module Archimate
  module DataModel
    class Viewpoint < NamedReferenceable
      using DataModel::DiffableArray
      using DataModel::DiffablePrimitive

      attribute :concern, ConcernList
      attribute :viewpointPurpose, ViewpointPurpose.optional
      attribute :viewpointContent, ViewpointContent.optional
      attribute :allowedElementTypes, AllowedElementTypes
      attribute :allowedRelationshipTypes, AllowedRelationshipTypes
      attribute :modelingNotes, Strict::Array.member(ModelingNote).default([])
    end

    Dry::Types.register_class(Viewpoint)
    ViewpointList = Strict::Array.member(Viewpoint).default([])
  end
end
