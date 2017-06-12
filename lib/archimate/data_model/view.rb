# frozen_string_literal: true

module Archimate
  module DataModel
    # This is a container for all of the Views in the model.
    class View < NamedReferenceable
      attribute :properties, PropertiesList
      attribute :viewpoint_type, ViewpointType.optional
      attribute :viewpoint, Identifier.optional
    end
  end
end
