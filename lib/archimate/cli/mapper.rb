# frozen_string_literal: true

module Archimate
  module Cli
    class Mapper
      HEADERS = %w[id name viewpoint].freeze
      COL_DIVIDER = " | "

      attr_reader :model

      def initialize(model, output_io)
        @model = model
        @output = output_io
      end

      def map
        widths = compute_column_widths(process_diagrams(model.diagrams), HEADERS)
        adjusted_widths = widths.inject(COL_DIVIDER.size * (HEADERS.size - 1), &:+)
        header_row(widths, HEADERS)
        organization_paths = build_organization_hash(model.organizations)
        organization_paths.keys.sort.each do |organization_name|
          diagrams = organization_paths[organization_name].select { |i| i.is_a?(DataModel::Diagram) }
          next if diagrams.empty?
          @output.puts(Color.color(format("%-#{adjusted_widths}s", organization_name), %i[bold green on_light_black]))
          output_diagrams(process_diagrams(diagrams), widths)
        end

        @output.puts "\n#{model.diagrams.size} Diagrams"
      end

      private

      def header_row(widths, headers)
        titles = widths
                 .zip(headers)
                 .map(&header_cell_format)
                 .join(col_divider)
        @output.puts titles
        @output.puts header_border(widths)
      end

      def col_divider
        Color.color(COL_DIVIDER, :light_black)
      end

      def header_border(widths)
        Color.color(widths.map { |w| "-" * w }.join("-+-"), :light_black)
      end

      def header_cell_format
        ->((width, header)) { Color.color(format("%-#{width}s", header).capitalize, %i[bold blue]) }
      end

      def process_diagrams(diagrams)
        diagrams.map do |diagram|
          [
            "#{diagram.id}.png",
            diagram.name.to_s,
            diagram.viewpoint_description
          ]
        end
      end

      def compute_column_widths(diagrams, headers)
        diagrams.each_with_object(headers.map(&:size)) do |diagram, memo|
          diagram.each_with_index do |o, i|
            memo[i] = !o.nil? && Color.uncolor(o).size > memo[i] ? Color.uncolor(o).size : memo[i]
          end
          memo
        end
      end

      def output_diagrams(diagrams, widths)
        diagrams.sort_by { |a| a[1] }.each do |m|
          @output.puts(
            widths
              .zip(m)
              .map { |(width, col)| format("%-#{width}s", col) }
              .join(Color.color(COL_DIVIDER, :light_black))
          )
        end
      end

      def build_organization_hash(organizations, parent = "", hash = {})
        organization_paths = organizations.each_with_object(hash) do |i, a|
          organization_path = [parent, i.name].join("/")
          a[organization_path] = i.items
          build_organization_hash(i.organizations, organization_path, a)
        end
        organization_paths = { "/" => model.diagrams } if organization_paths.empty?
        organization_paths
      end
    end
  end
end
