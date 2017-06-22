# frozen_string_literal: true

module Archimate
  module DataModel
    # An element that holds documentation.
    # A base string type for multi-language strings that preserves whitespace.
    # PreservedLangStringType in ArchiMate 3 schema
    class Documentation < LangString
    end

    Dry::Types.register_class(Documentation)
    DocumentationGroup = Strict::Array.member(Documentation).default([])
  end
end
