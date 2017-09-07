# frozen_string_literal: true

module Archimate
  # Support Archimate file format versions
  SUPPORTED_FORMATS = %i[
    archi_3
    archi_4
    archimate_2_1
    archimate_3_0
  ].freeze

  # Archimate modeling specification version
  ARCHIMATE_VERSIONS = %i[
    archimate_2_1
    archimate_3_0
  ].freeze

  module Cli
    autoload :Archi, 'archimate/cli/archi'
    autoload :Cleanup, 'archimate/cli/cleanup'
    autoload :ConflictResolver, 'archimate/cli/conflict_resolver'
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
    autoload :Jsonl, 'archimate/export/jsonl'
  end

  module FileFormats
    autoload :ArchiFileFormat, 'archimate/file_formats/archi_file_format'
    autoload :ArchiFileReader, 'archimate/file_formats/archi_file_reader'
    autoload :ArchiSaxDocument, 'archimate/file_formats/archi_sax_document'
    autoload :ArchiFileWriter, 'archimate/file_formats/archi_file_writer'
    autoload :ModelExchangeFileReader, 'archimate/file_formats/model_exchange_file_reader'
    autoload :ModelExchangeFileWriter21, 'archimate/file_formats/model_exchange_file_writer_21'
    autoload :ModelExchangeFileWriter30, 'archimate/file_formats/model_exchange_file_writer_30'
    autoload :Reader, 'archimate/file_formats/reader'
    autoload :SaxHandler, 'archimate/file_formats/sax_handler'
    autoload :Serializer, 'archimate/file_formats/serializer'
  end

  module Lint
    autoload :DuplicateEntities, 'archimate/lint/duplicate_entities'
    autoload :Linter, 'archimate/lint/linter'
  end

  module Svg
    autoload :Child, 'archimate/svg/child'
    autoload :CssStyle, 'archimate/svg/css_style'
    autoload :Connection, 'archimate/svg/connection'
    autoload :Diagram, 'archimate/svg/diagram'
    autoload :Entity, 'archimate/svg/entity'
    autoload :EntityFactory, 'archimate/svg/entity_factory'
    autoload :Extents, 'archimate/svg/extents'
    autoload :Point, 'archimate/svg/point'
    autoload :SvgTemplate, 'archimate/svg/svg_template'
  end

  autoload :FileFormat, 'archimate/file_format'
  autoload :MaybeIO, 'archimate/maybe_io'
  autoload :ProgressIndicator, 'archimate/progress_indicator'

  require "archimate/version"
  require "archimate/config"
  require "archimate/logging"
  require "archimate/color"
  require 'archimate/data_model'
  # require 'archimate/diff'

  # Computes the set of differences between base and remote models
  def self.diff(base, remote)
    base.diff(remote)
  end

  # Reads the given file and returns the Archimate model
  #
  # @param filename File name of the file to read
  # @return Archimate::DataModel::Model of ArchiMate model in the file
  def self.read(filename)
    raise "#{filename.inspect} not found" unless File.exist?(filename)
    FileFormat.read(filename)
  end

  # Reads the given file and returns the Archimate model
  #
  # @param str XML string containing the Archimate model
  # @return Archimate::DataModel::Model of ArchiMate model in the file
  def self.parse(str)
    FileFormat.parse(str)
  end
end
