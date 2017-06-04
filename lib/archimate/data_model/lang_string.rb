# frozen_string_literal: true

module Archimate
  module DataModel
    class LangString < ArchimateNode
      attribute :content, Strict::String
      attribute :lang, Strict::String.optional
    end

    Dry::Types.register_class(LangString)
  end
end
