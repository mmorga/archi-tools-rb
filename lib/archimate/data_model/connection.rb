# frozen_string_literal: true

module Archimate
  module DataModel
    # Graphical connection type.
    #
    # If the 'relationshipRef' attribute is present, the connection should reference an existing ArchiMate relationship.
    #
    # If the connection is an ArchiMate relationship type, the connection's label, documentation and properties may be determined
    # (i.e inherited) from those in the referenced ArchiMate relationship. Otherwise the connection's label, documentation and properties
    # can be provided and will be additional to (or over-ride) those contained in the referenced ArchiMate relationship.
    class Connection < ViewConcept
      attribute :source_attachment, Location.optional
      attribute :bendpoint, Strict::Array.member(Location).default([])
      attribute :target_attachment, Location.optional
      attribute :source, Identifier.optional
      attribute :target, Identifier.optional
    end

    Dry::Types.register_class(Connection)
  end
end
