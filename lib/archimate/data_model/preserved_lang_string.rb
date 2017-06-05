# frozen_string_literal: true

module Archimate
  module DataModel
    class PreservedLangString < LangString
      def initialize(*args)
        super
        @whitespace = :preserve
      end
    end

    Dry::Types.register_class(PreservedLangString)
  end
end
