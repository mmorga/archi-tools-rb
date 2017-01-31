# frozen_string_literal: true
require "highline"
require "dry-types"
require "dry-struct"
require "archimate/version"
require 'archimate/data_model'
require 'archimate/diff'
require 'archimate/aio'

module Archimate
  module Cli
    autoload :Archi, 'archimate/cli/archi'
    autoload :Cleanup, 'archimate/cli/cleanup'
    autoload :Convert, 'archimate/cli/convert'
    autoload :Diff, 'archimate/cli/diff'
    autoload :DiffSummary, 'archimate/cli/diff_summary'
    autoload :Duper, 'archimate/cli/duper'
    autoload :Lint, 'archimate/cli/lint'
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

  module FileFormats
    autoload :ArchimateV2, 'archimate/file_formats/archimate_v2'
    autoload :ArchiFileFormat, 'archimate/file_formats/archi_file_format'
    autoload :ArchiFileReader, 'archimate/file_formats/archi_file_reader'
    autoload :ArchiFileWriter, 'archimate/file_formats/archi_file_writer'
    autoload :ModelExchangeFileFormat, 'archimate/file_formats/model_exchange_file_format'
    autoload :ModelExchangeFileReader, 'archimate/file_formats/model_exchange_file_reader'
    autoload :ModelExchangeFileWriter, 'archimate/file_formats/model_exchange_file_writer'
    autoload :Writer, 'archimate/file_formats/writer'
  end

  module Lint
    autoload :Linter, 'archimate/lint/linter'
  end

  module Svg
    autoload :Child, 'archimate/svg/child'
    autoload :Connection, 'archimate/svg/connection'
    autoload :Diagram, 'archimate/svg/diagram'
    autoload :Entity, 'archimate/svg/entity'
    autoload :EntityFactory, 'archimate/svg/entity_factory'
    autoload :Export, 'archimate/svg/export'
    autoload :Extents, 'archimate/svg/extents'
    autoload :Point, 'archimate/svg/point'
    autoload :SvgTemplate, 'archimate/svg/svg_template'
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
end
