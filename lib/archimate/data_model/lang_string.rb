# frozen_string_literal: true

require "forwardable"

module Archimate
  module DataModel
    # A base string type for multi-language strings.
    class LangString
      include Comparison
      extend Forwardable

      def_delegators :@default_text, :strip, :tr, :+, :gsub, :sub, :downcase, :empty?, :split
      def_delegators :@lang_hash, :size

      model_attr :lang_hash # Strict::Hash
      model_attr :default_lang # Strict::String.optional.default(nil)
      model_attr :default_text # Strict::String

      # def self.default_lang
      #   Archimate::Config.instance.default_lang
      # end

      def self.string(str, lang = nil)
        return nil if !str || str.strip.empty?
        str = str.strip
        lang = nil if !lang || lang.empty?
        new(
          lang_hash: { lang => str },
          default_lang: lang,
          default_text: str
        )
      end

      def self.create(copy)
        case copy
        when String
          string(copy)
        when LangString
          copy
        when Hash
          lang_hash = copy.fetch(:lang_hash, {})
          default_lang = copy.fetch(:default_lang, "")
          default_text = copy.fetch(:default_text, "")
          return nil if [lang_hash, default_lang, default_text].any? { |i| i && i.empty? }
          new(
            lang_hash: lang_hash,
            default_lang: default_lang,
            default_text: default_text
          )
        end
      end

      # @param [Hash{Symbol => Object},LangString, String] attributes
      # @raise [Struct::Error] if the given attributes don't conform {#schema}
      #   with given {# # constructor_type}
      def initialize(str = nil, lang_hash: {}, default_lang: nil, default_text: nil)
        @lang_hash = lang_hash
        @default_lang = default_lang
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
