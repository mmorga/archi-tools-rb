module Archimate
  module Model
    module Types
      include Dry::Types.module

      ElementHash = Strict::Hash

      DiagramHash = Strict::Hash

      RelationshipHash = Strict::Hash

      ElementIdList = Strict::Array.member(Strict::String)

      Dry::Types.register_class(Bendpoint)
      Bendpoint = Dry::Types['archimate.model.bendpoint']
      BendpointList = Strict::Array.member(Bendpoint)

      DocumentationList = Strict::Array.member(Strict::String)

      Dry::Types.register_class(Property)
      Property = Dry::Types['archimate.model.property']

      PropertiesList = Strict::Array.member(Property)

      FolderHash = Strict::Hash

      Dry::Types.register_class(Folder)
      Folder = Dry::Types['archimate.model.folder']

      Dry::Types.register_class(Bounds)
      Bounds = Dry::Types['archimate.model.bounds']
      OptionalBounds = Bounds.optional

      Dry::Types.register_class(Relationship)
      Relationship = Dry::Types['archimate.model.relationship']

      Dry::Types.register_class(SourceConnection)
      SourceConnection = Dry::Types['archimate.model.source_connection']

      SourceConnectionList = Strict::Array.member("archimate.model.source_connection")

      Dry::Types.register_class(Child)
      Child = Dry::Types['archimate.model.child']

      ChildHash = Strict::Hash

      Dry::Types.register_class(Organization)
      Organization = Dry::Types['archimate.model.organization']
    end
  end
end
