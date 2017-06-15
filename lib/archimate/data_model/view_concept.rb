# frozen_string_literal: true

module Archimate
  module DataModel
    # This is an abstract super-type of Node and Connection.
    class ViewConcept < ArchimateNode
      attribute :id, Identifier
      attribute :labels, Strict::Array.member(LangString).constrained(min_size: 1)
      attribute :documentation, DocumentationGroup
      attribute :style, Style.optional
      # the "viewRef" of an "Concept" is to a view that allows drill-down diagrams.
      attribute :view_refs, Strict::Array.member(Identifier)
      # TODO: any other attributes
    end

    Dry::Types.register_class(ViewConcept)
  end
end
