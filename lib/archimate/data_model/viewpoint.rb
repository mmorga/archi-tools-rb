module Archimate
  module DataModel
    class Viewpoint < NamedReferenceable
      attribute :properties, Strict::Array.members(Property).default([])
      attribute :concern, Concern.optional
      attribute :purpose, ViewpointPurpose.optional
      attribute :content, ViewpointContent.optional
      attribute :allowedElementTypes, Strict::Array.members(AllowedElement).default([])
      attribute :allowedRelationshipTypes, Strict::Array.members(AllowedRelationship).default([])
      attribute :modelingNotes, Strict::Array.members(ModelingNote).default([])
    end
  end
end
