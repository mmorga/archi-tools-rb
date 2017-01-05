# frozen_string_literal: true
require "highline"
require "dry-types"
require "dry-struct"
require "archimate/version"
require 'archimate/data_model'
require 'archimate/aio'

module Archimate
  module Cli
    autoload :Archi, 'archimate/cli/archi'
    autoload :Cleanup, 'archimate/cli/cleanup'
    autoload :Convert, 'archimate/cli/convert'
    autoload :Diff, 'archimate/cli/diff'
    autoload :DiffSummary, 'archimate/cli/diff_summary'
    autoload :Duper, 'archimate/cli/duper'
    autoload :Mapper, 'archimate/cli/mapper'
    autoload :Merge, 'archimate/cli/merge'
    autoload :Merger, 'archimate/cli/merger'
    autoload :Stats, 'archimate/cli/stats'
    autoload :Svger, 'archimate/cli/svger'
  end

  module Export
    autoload :NQuads, 'archimate/export/n_quads'
    autoload :GraphML, 'archimate/export/graph_ml'
    autoload :CSVExport, 'archimate/export/csv_export'
    autoload :Cypher, 'archimate/export/cypher'
  end

  module Diff
    autoload :ArchimateIdentifiedNodeReference, 'archimate/diff/archimate_identified_node_reference'
    autoload :ArchimateArrayReference, 'archimate/diff/archimate_array_reference'
    autoload :ArchimateNodeAttributeReference, 'archimate/diff/archimate_node_attribute_reference'
    autoload :ArchimateNodeReference, 'archimate/diff/archimate_node_reference'
    autoload :Change, 'archimate/diff/change'
    autoload :Conflict, 'archimate/diff/conflict'
    autoload :Conflicts, 'archimate/diff/conflicts'
    autoload :Context, 'archimate/diff/context'
    autoload :Delete, 'archimate/diff/delete'
    autoload :Difference, 'archimate/diff/difference'
    autoload :Insert, 'archimate/diff/insert'
    autoload :Merge, 'archimate/diff/merge'
    autoload :Move, 'archimate/diff/move'
  end

  module FileFormats
    autoload :ArchiFileFormat, 'archimate/file_formats/archi_file_format'
    autoload :ArchiFileReader, 'archimate/file_formats/archi_file_reader'
    autoload :ArchiFileWriter, 'archimate/file_formats/archi_file_writer'
    autoload :ModelExchangeFileFormat, 'archimate/file_formats/model_exchange_file_format'
    autoload :ModelExchangeFileReader, 'archimate/file_formats/model_exchange_file_reader'
    autoload :ModelExchangeFileWriter, 'archimate/file_formats/model_exchange_file_writer'
    autoload :Writer, 'archimate/file_formats/writer'
  end

  autoload :FileFormat, 'archimate/file_format'
  autoload :MaybeIO, 'archimate/maybe_io'

  def self.diff(base, remote)
    base.diff(remote)
  end

  # Reads the given file and returns the Archimate model
  #
  # @param filename File name of the file to read
  # @return Archimate::DataModel::Model of ArchiMate model in the file
  def self.read(filename, aio)
    FileFormat.read(filename, aio)
  end

  # Reads the given file and returns the Archimate model
  #
  # @param filename File name of the file to read
  # @return Archimate::DataModel::Model of ArchiMate model in the file
  def self.parse(filename, aio)
    FileFormat.parse(filename, aio)
  end

  using DataModel::DiffablePrimitive
  using DataModel::DiffableArray

  # Produces a NodeReference instance for the given parameters
  def self.node_reference(node, child_node = nil)
    return Diff::ArchimateIdentifiedNodeReference.new(node) if child_node.nil? && node.is_a?(DataModel::Model)

    if child_node.nil? && !node.is_a?(DataModel::Model)
      case node.parent
      when DataModel::ArchimateNode
        Diff::ArchimateNodeReference.for_node(node.parent, node.parent.parent_attribute_name)
      when Array, DataModel::BaseArray
        Diff::ArchimateNodeReference.for_node(node.parent, node.parent.index(node))
      else
        raise "Whoops! was a #{node.parent.class}"
      end
    else
      Diff::ArchimateNodeReference.for_node(node, child_node)
    end
  end
end
