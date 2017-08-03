# frozen_string_literal: true

module Archimate
  module DataModel
    # A base string type for multi-language strings that preserves whitespace.
    # PreservedLangStringType in ArchiMate 3 schema
    class PreservedLangString < LangString
      def self.blank
        super
      end
    end

    Dry::Types.register_class(PreservedLangString)
  end
end
