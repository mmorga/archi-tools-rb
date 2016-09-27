module Archimate
  module Model
    class SourceConnection < Dry::Struct::Value
      attribute :id, Archimate::Model::Strict::String
      attribute :type, Archimate::Model::Strict::String
      attribute :source, Archimate::Model::Strict::String
      attribute :target, Archimate::Model::Strict::String
      attribute :relationship, Archimate::Model::Strict::String
      attribute :bendpoints, Archimate::Model::BendpointList

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
