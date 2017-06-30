# frozen_string_literal: true
require "forwardable"

module Archimate
  module DataModel
    # A base string type for multi-language strings.
    class LangString < ArchimateNode
      # include Comparable
      extend Forwardable
      def_delegators :@text, :to_s, :strip, :strip!, :tr, :+, :gsub, :gsub!, :sub!, :downcase!, :empty?, :split

      attribute :text, Strict::String
      attribute :lang, Strict::String.optional

      # @param [Hash{Symbol => Object},Dry::Struct, String] attributes
      # @raise [Struct::Error] if the given attributes don't conform {#schema}
      #   with given {#constructor_type}
      def self.new(attributes)
        if attributes.instance_of?(String)
          super(text: attributes.strip)
        else
          super
        end
      end

      def to_str
        @text
      end

      def =~(other)
        if other.is_a?(Regexp)
          other =~ @text
        else
          Regexp.new(Regexp.escape(@text)) =~ other
        end
      end
    end

    Dry::Types.register_class(LangString)
  end
end
