# frozen_string_literal: true

require "forwardable"

module Archimate
  module DataModel
    # A base string type for multi-language strings.
    class LangString
      include Comparison
      extend Forwardable

      def_delegators :@default_text, :strip, :tr, :+, :gsub, :sub, :downcase, :empty?, :split, :size, :include?

      # @!attribute [r] lang_hash
      #   @return [Hash]
      model_attr :lang_hash
      # @!attribute [r] default_lang
      #   @return [String, NilClass]
      model_attr :default_lang
      # @!attribute [r] default_text
      #   @return [String]
      model_attr :default_text

      def self.string(str, lang = nil)
        return nil if !str || str.strip.empty?
        new(str, lang)
      end

      # @param [Hash{Symbol => Object},LangString, String] attributes
      # @raise [Struct::Error] if the given attributes don't conform {#schema}
      #   with given {# # constructor_type}
      def initialize(str = nil, lang = nil, lang_hash: {}, default_lang: nil, default_text: nil)
        @lang_hash = lang_hash
        @default_lang = default_lang || lang
        @default_text = default_text
        case str
        when String
          @lang_hash[@default_lang] = @default_text = str.strip
        when LangString
          @lang_hash = str.lang_hash
          @default_lang = str.default_lang
          @default_text = str.default_text
        else
          @lang_hash[default_lang] = default_text if default_text
        end
      end

      def langs
        @lang_hash.keys
      end

      def to_str
        to_s
      end

      def to_s
        @default_text ||= @lang_hash.fetch(default_lang) do |key|
          @lang_hash.fetch(nil, nil) if key
        end
      end

      def by_lang(lang)
        lang_hash.fetch(lang, nil)
      end

      def text
        to_s
      end

      def lang
        default_lang
      end

      def =~(other)
        str = to_s
        if other.is_a?(Regexp)
          other =~ str
        else
          Regexp.new(Regexp.escape(str)) =~ other
        end
      end
    end
  end
end
