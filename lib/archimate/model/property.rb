# frozen_string_literal: true
module Archimate
  module Model
    class Property < Dry::Struct::Value
      attribute :key, Archimate::Types::Strict::String
      attribute :value, Archimate::Types::Strict::String.optional

      def self.create(options = {})
        new_opts = {
          value: nil
        }.merge(options)
        Property.new(new_opts)
      end

      def with(options = {})
        Property.new(to_h.merge(options))
      end
    end
  end
end
