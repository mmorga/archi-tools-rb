# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        class ModelExchangeFileWriter < Writer
          attr_reader :model

          def initialize(model)
            super
          end

          def write(output_io)
            builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
              serialize_model(xml, model)
            end
            output_io.write(builder.to_xml)
          end

          # TODO: Archi uses hex numbers for ids which may not be valid for
          # identifer. If we are converting from Archi, decorate the IDs here.
          def identifier(str)
            return "id-#{str}" if str =~ /\A\d/
            str
          end
        end
      end
    end
  end
end
