# frozen_string_literal: true
require "csv"

# This module takes an ArchiMate model and builds a set of CSV files representing it.
module Archimate
  module Export
    class CSVExport
      attr_reader :model

      def initialize(model)
        @model = model
      end

      def to_csv(output_dir: ".")
        (model.relationships + model.elements)
          .group_by(&:type).each do |type, elements|
          CSV.open(
            File.join(output_dir, "#{type}.csv"),
            "wb",
            force_quotes: true
          ) do |csv|
            headers = elements.first.class.attr_names
            csv << headers.map(&:to_s)
            elements.each do |element|
              csv << headers.map { |attr| element.send(attr) }
            end
          end
        end
      end
    end
  end
end
