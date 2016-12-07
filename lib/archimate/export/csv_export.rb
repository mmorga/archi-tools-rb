# frozen_string_literal: true
require "csv"

# This module takes an ArchiMate model and builds GraphML representation of it.
module Archimate
  module Export
    class CSVExport
      attr_reader :model

      def initialize(model)
        @model = model
      end

      def to_csv(output_directory: ".")
        (model.relationships + model.elements)
          .group_by(&:type).each do |type, elements|
          CSV.open(
            File.join(output_directory, "#{type}.csv"),
            "wb",
            force_quotes: true
          ) do |csv|
            headers = elements.first.struct_instance_variables
            csv << headers.map(&:to_s)
            elements.each do |element|
              csv << csv.headers.map { |attr| element[attr] }
            end
          end
        end
      end
    end
  end
end
