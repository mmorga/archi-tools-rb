module Archimate
  module Model
    class Organization < Dry::Struct::Value
      attribute :folders, Types::FolderHash

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
  end
end
