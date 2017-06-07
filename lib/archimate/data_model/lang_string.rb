# frozen_string_literal: true

module Archimate
  module DataModel
    # A base string type for multi-language strings.
    class LangString < ArchimateNode
      attribute :text, Strict::String
      attribute :lang, Strict::String.default("en") # TODO: by the spec should be optional

      def to_s
        "#{self.class.name.split('::').last}<#{object_id}>[#{[lang, text].compact.join(',')}]"
      end
    end

    Dry::Types.register_class(LangString)
  end
end
