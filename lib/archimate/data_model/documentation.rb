# frozen_string_literal: true
module Archimate
  module DataModel
    class Documentation < PreservedLangString
    end

    Dry::Types.register_class(Documentation)
    DocumentationList = Strict::Array.member(Documentation).default([])
  end
end
