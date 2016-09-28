module Archimate
  module DataModel
    class SourceConnection < Dry::Struct::Value
      attribute :id, Strict::String
      attribute :type, Strict::String
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :relationship, Strict::String
      attribute :bendpoints, BendpointList

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
    Dry::Types.register_class(SourceConnection)
    SourceConnectionList = Strict::Array.member("archimate.data_model.source_connection")
  end
end
