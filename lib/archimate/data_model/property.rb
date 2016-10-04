# frozen_string_literal: true
module Archimate
  module DataModel
    class Property < Dry::Struct::Value
      include DataModel::With

      attribute :key, Strict::String
      attribute :value, Strict::String.optional

      def self.create(options = {})
        new_opts = {
          value: nil
        }.merge(options)
        Property.new(new_opts)
      end
    end

    Dry::Types.register_class(Property)
    PropertiesList = Strict::Array.member(Property)
  end
end
