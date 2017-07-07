# frozen_string_literal: true

module Archimate
  module DataModel
    # This is a container for all of the Views in the model.
    class View < NamedReferenceable
      attribute :properties, PropertiesList
      attribute :viewpoint_type, Strict::String.optional # TODO: ViewpointType.optional is better, but is ArchiMate version dependent. Need to figure that out
      attribute :viewpoint, Viewpoint.optional
    end
  end
end
