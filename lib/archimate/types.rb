module Archimate
  module Types
    include Dry::Types.module

    Dry::Types.register_class(Archimate::Model::Bendpoint)
    Bendpoint = Dry::Types['archimate.model.bendpoint']
    BendpointList = Strict::Array.member(Bendpoint)

    DocumentationList = Strict::Array.member(Strict::String)

    Dry::Types.register_class(Archimate::Model::Property)
    Property = Dry::Types['archimate.model.property']

    PropertiesList = Strict::Array.member(Property)

    Dry::Types.register_class(Archimate::Model::Folder)
    Folder = Dry::Types['archimate.model.folder']

    Dry::Types.register_class(Archimate::Model::Bounds)
    Bounds = Dry::Types['archimate.model.bounds']
    OptionalBounds = Bounds.optional

    Dry::Types.register_class(Archimate::Model::Relationship)
    Relationship = Dry::Types['archimate.model.relationship']

    Dry::Types.register_class(Archimate::Model::SourceConnection)
    SourceConnection = Dry::Types['archimate.model.source_connection']

    Dry::Types.register_class(Archimate::Model::Child)
    Child = Dry::Types['archimate.model.child']

    Dry::Types.register_class(Archimate::Model::Organization)
    Organization = Dry::Types['archimate.model.organization']
  end
end
