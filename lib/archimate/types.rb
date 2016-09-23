module Archimate
  module Types
    Dry::Types.load_extensions(:maybe)
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
  end
end
