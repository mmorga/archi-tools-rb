# frozen_string_literal: true
module Archimate
  module DataModel
    class SourceConnection < IdentifiedNode
      attribute :name, Strict::String.optional
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :relationship, Strict::String.optional
      attribute :bendpoints, BendpointList
      attribute :style, Style.optional

      def type_name
        HighLine.color("#{AIO.data_model('SourceConnection')}[#{HighLine.color(@name || '', [:white, :underline])}]", :on_light_magenta)
      end

      def to_s
        if in_model
          s = in_model.lookup(source) unless source.nil?
          t = in_model.lookup(target) unless target.nil?
        else
          s = source
          t = target
        end
        "#{type_name} #{s.nil? ? 'nothing' : s} -> #{t.nil? ? 'nothing' : t}"
      end

      def referenced_identified_nodes
        [@source, @target, @relationship].compact
      end
    end
    Dry::Types.register_class(SourceConnection)
    SourceConnectionList = Strict::Array.member("archimate.data_model.source_connection").default([])
  end
end
