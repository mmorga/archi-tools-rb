# frozen_string_literal: true
module Archimate
  module DataModel
    # TODO: this really serves no purpose in the datamodel. remove this and
    # bump up its folders attribute into Model.
    class Organization < Dry::Struct::Value
      include DataModel::With

      attribute :folders, Strict::Hash

      def self.create(options = {})
        new_opts = {
          folders: {}
        }.merge(options)
        Organization.new(new_opts)
      end
    end
    Dry::Types.register_class(Organization)
  end
end
