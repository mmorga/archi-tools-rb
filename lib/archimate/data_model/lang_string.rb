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
      # @return [Hash]
      model_attr :lang_hash
      # @!attribute [r] default_lang
      # @return [String, NilClass]
      model_attr :default_lang
      # @!attribute [r] default_text
      # @return [String]
      model_attr :default_text

      def self.string(str, lang = nil)
        return nil if !str || str.strip.empty?
        new(str, default_lang: lang)
      end

      # @param str [String, LangString] optional shortcut to set define this LangString
      # @param lang_hash [Hash{Symbol => Object}] attributes
      # @param default_lang [String] optional setting of the default language
      # @raise [Struct::Error] if the given attributes don't conform {#schema}
      #   with given {# # constructor_type}
      def initialize(str = nil, lang_hash: {}, default_lang: nil)
        @lang_hash = lang_hash
        @default_lang = default_lang || lang_hash.keys.first
        @default_text = str || lang_hash.fetch(@default_lang, nil)
        case str
        when String
          @lang_hash[@default_lang] = @default_text = str.strip
        when LangString
          @lang_hash = str.lang_hash
          @default_lang = str.default_lang
          @default_text = str.default_text
        else
          @lang_hash[default_lang] = @default_text if @default_text
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

      def merge(other)
        return unless other
        other.lang_hash.each do |k, v|
          if @lang_hash.include?(k)
            @lang_hash[k] = [@lang_hash[k], v].join("\n") if @lang_hash[k] != other.lang_hash[k]
          else
            @lang_hash[k] = v
          end
        end
        @default_lang = @default_lang || other.default_lang || @lang_hash.keys.first
        @default_text = @lang_hash[@default_lang]
      end
    end
  end
end
