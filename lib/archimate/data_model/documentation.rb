# frozen_string_literal: true

module Archimate
  module DataModel
    # An element that holds documentation.
    class Documentation < PreservedLangString
    end

    Dry::Types.register_class(Documentation)
    DocumentationList = Strict::Array.member(Documentation).default([])
    DocumentationGroup = Strict::Array.member(Documentation).default([])
  end
end
