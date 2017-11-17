# frozen_string_literal: true

require "nokogiri"

module Archimate
  module FileFormats
    module Serializer
      module Archi
        class ArchiFileWriter < Serializer::Writer
          include Serializer::Archi::Bounds
          include Serializer::Archi::Connection
          include Serializer::Archi::Diagram
          include Serializer::Archi::Documentation
          include Serializer::Archi::Element
          include Serializer::Archi::Model
          include Serializer::Archi::Organization
          include Serializer::Archi::Property
          include Serializer::Archi::Relationship
          include Serializer::Archi::ViewNode
          include Serializer::Archi::Viewpoint3

          TEXT_SUBSTITUTIONS = [
            ['&#13;', '&#xD;'],
            ['"', '&quot;'],
            ['&gt;', '>'],
            ['&#38;', '&amp;']
          ].freeze

          def initialize(model)
            super
            @version = "3.1.1"
          end

          def process_text(doc_str)
            %w(documentation content name).each do |tag|
              TEXT_SUBSTITUTIONS.each do |from, to|
                doc_str.gsub!(%r{<#{tag}>([^<]*#{from}[^<]*)</#{tag}>}) do |str|
                  str.gsub(from, to)
                end
              end
            end
            doc_str.gsub(
              %r{<(/)?archimate:}, "<\\1"
            ).gsub(
              %r{<(/)?model}, "<\\1archimate:model"
            )
          end

          def write(archifile_io)
            builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
              serialize_model(xml, model)
            end
            archifile_io.write(
              process_text(
                builder.to_xml
              )
            )
          end
        end
      end
    end
  end
end
