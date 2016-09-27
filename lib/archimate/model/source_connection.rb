module Archimate
  module Model
    class SourceConnection < Dry::Struct::Value
      attribute :id, Types::Strict::String
      attribute :type, Types::Strict::String
      attribute :source, Types::Strict::String
      attribute :target, Types::Strict::String
      attribute :relationship, Types::Strict::String
      attribute :bendpoints, Types::BendpointList

      def self.create(options = {})
        new_opts = {
          type: nil,
          source: nil,
          target: nil,
          relationship: nil,
          bendpoints: []
        }.merge(options)
        SourceConnection.new(new_opts)
      end

      def with(options = {})
        SourceConnection.new(to_h.merge(options))
      end
    end
  end
end
