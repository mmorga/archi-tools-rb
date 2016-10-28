# frozen_string_literal: true
require "nokogiri"
require "highline"
require "colorize"
require "dry-types"
require "dry-struct"
require "archimate/version"
require 'archimate/data_model'

module Archimate
  module Cli
    autoload :Archi, 'archimate/cli/archi'
    autoload :Cleanup, 'archimate/cli/cleanup'
    autoload :Convert, 'archimate/cli/convert'
    autoload :Diff, 'archimate/cli/diff'
    autoload :Duper, 'archimate/cli/duper'
    autoload :Mapper, 'archimate/cli/mapper'
    autoload :Merge, 'archimate/cli/merge'
    autoload :Merger, 'archimate/cli/merger'
    autoload :Projector, 'archimate/cli/projector'
    autoload :Svger, 'archimate/cli/svger'
    autoload :XmlTextconv, 'archimate/cli/xml_textconv'
  end

  module Conversion
    autoload :ArchiFileFormat, 'archimate/conversion/archi_file_format'
    autoload :ModelExchangeFileFormat, 'archimate/conversion/model_exchange_file_format'
    autoload :ArchiToMeff, 'archimate/conversion/archi_to_meff'
    autoload :Quads, 'archimate/conversion/quads'
    autoload :GraphML, 'archimate/conversion/graph_ml'
  end

  module Diff
    autoload :Change, 'archimate/diff/change'
    autoload :Conflict, 'archimate/diff/conflict'
    autoload :Conflicts, 'archimate/diff/conflicts'
    autoload :Context, 'archimate/diff/context'
    autoload :Delete, 'archimate/diff/delete'
    autoload :Difference, 'archimate/diff/difference'
    autoload :Insert, 'archimate/diff/insert'
    autoload :Merge, 'archimate/diff/merge'
  end

  autoload :AIO, 'archimate/aio'
  autoload :ArchiFileReader, 'archimate/archi_file_reader'
  autoload :Constants, 'archimate/constants'
  autoload :Diff, 'archimate/diff'
  autoload :Document, 'archimate/document'
  autoload :MaybeIO, 'archimate/maybe_io'
  autoload :OutputIO, 'archimate/output_io'

  # Creates a new generic xml document given an optional string source
  #
  # @param xml_str Optional string of xml to parse as initial document
  def self.new_xml_doc(xml_str = nil)
    Nokogiri::XML::Document.new(xml_str)
  end

  def self.parse_xml(xml_str)
    Nokogiri::XML(xml_str)
  end

  def self.array_to_id_hash(ary)
    Array(ary).each_with_object({}) { |i, a| a[i.id] = i }
  end

  def self.diff(local, remote)
    Diff::Context.new(local, remote, local, remote).diffs
  end

  def self.debug_puts(msg, diffs)
    puts "\n#{msg}"
    puts "\t" + diffs.map(&:to_s).join("\n\t")
  end
end
