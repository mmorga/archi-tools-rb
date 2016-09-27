module Archimate
  module Model
    include Dry::Types.module

    ElementHash = Strict::Hash

    DiagramHash = Strict::Hash

    RelationshipHash = Strict::Hash

    ElementIdList = Strict::Array.member(Strict::String)

    Dry::Types.register_class(Bendpoint)
    BendpointType = Dry::Types['archimate.model.bendpoint']
    BendpointList = Strict::Array.member(BendpointType)

    DocumentationList = Strict::Array.member(Strict::String)

    Dry::Types.register_class(Property)
    PropertyType = Dry::Types['archimate.model.property']

    PropertiesList = Strict::Array.member(PropertyType)

    FolderHash = Strict::Hash

    Dry::Types.register_class(Folder)
    FolderType = Dry::Types['archimate.model.folder']

    Dry::Types.register_class(Bounds)
    BoundsType = Dry::Types['archimate.model.bounds']
    OptionalBounds = Bounds.optional

    Dry::Types.register_class(Relationship)
    RelationshipType = Dry::Types['archimate.model.relationship']

    Dry::Types.register_class(SourceConnection)
    SourceConnectionType = Dry::Types['archimate.model.source_connection']

    SourceConnectionList = Strict::Array.member("archimate.model.source_connection")

    Dry::Types.register_class(Child)
    ChildType = Dry::Types['archimate.model.child']

    ChildHash = Strict::Hash

    Dry::Types.register_class(Organization)
    OrganizationType = Dry::Types['archimate.model.organization']
  end
end
