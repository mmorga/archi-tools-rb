module Archimate
  module Model
    class SourceConnection < Dry::Struct::Value
      attribute :id, Archimate::Types::Strict::String
      attribute :type, Archimate::Types::Strict::String
      attribute :source, Archimate::Types::Strict::String
      attribute :target, Archimate::Types::Strict::String
      attribute :relationship, Archimate::Types::Strict::String
      attribute :bendpoints, Archimate::Types::BendpointList

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
