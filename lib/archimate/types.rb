module Archimate
  module Types
    include Dry::Types.module

    Dry::Types.register_class(Archimate::Model::Folder)
    Folder = Dry::Types['archimate.model.folder']

    Dry::Types.register_class(Archimate::Model::Bounds)
    Bounds = Dry::Types['archimate.model.bounds']
    OptionalBounds = Bounds.optional

    Dry::Types.register_class(Archimate::Model::SourceConnection)
    SourceConnection = Dry::Types['archimate.model.source_connection']

    Dry::Types.register_class(Archimate::Model::Child)
    Child = Dry::Types['archimate.model.child']

    Dry::Types.register_class(Archimate::Model::Organization)
    Organization = Dry::Types['archimate.model.organization']

    Dry::Types.register_class(Archimate::Model::Property)
    Property = Dry::Types['archimate.model.property']

    DocumentationList = Archimate::Types::Strict::Array.member(Archimate::Types::Strict::String)

    PropertiesList = Archimate::Types::Strict::Array.member(Archimate::Types::Property)
  end
end
