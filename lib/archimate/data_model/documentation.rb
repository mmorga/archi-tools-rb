# frozen_string_literal: true
module Archimate
  module DataModel
    class Documentation < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :lang, Strict::String.optional
      attribute :text, Strict::String

      def comparison_attributes
        [:@lang, :@text]
      end

      def to_s
        "Documentation<#{object_id}>[#{[lang, text].compact.join(',')}]"
      end
    end

    Dry::Types.register_class(Documentation)
    DocumentationList = Strict::Array.member(Documentation)
  end
end
