module Archimate
  module DataModel
    class Organization < Dry::Struct::Value
      attribute :folders, Strict::Hash

      def self.create(options = {})
        new_opts = {
          folders: {}
        }.merge(options)
        Organization.new(new_opts)
      end

      def with(options = {})
        Organization.new(to_h.merge(options))
      end
    end
    Dry::Types.register_class(Organization)
  end
end
