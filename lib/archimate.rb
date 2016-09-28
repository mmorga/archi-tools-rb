# frozen_string_literal: true
require "nokogiri"
require "highline"
require "dry-types"
require "dry-struct"
require "archimate/version"
require 'archimate/data_model'

module Archimate
  # The root path for YARD source libraries
  ROOT = File.expand_path(File.dirname(__FILE__))

  module Cli
    autoload :Archi, 'archimate/cli/archi'
    autoload :Cleanup, 'archimate/cli/cleanup'
    autoload :Convert, 'archimate/cli/convert'
    autoload :Diff, 'archimate/cli/diff'
    autoload :Duper, 'archimate/cli/duper'
    autoload :Mapper, 'archimate/cli/mapper'
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
    autoload :Context, 'archimate/diff/context'
    autoload :Difference, 'archimate/diff/difference'
    autoload :ElementDiff, 'archimate/diff/element_diff'
    autoload :FolderDiff, 'archimate/diff/folder_diff'
    autoload :IdHashDiff, 'archimate/diff/id_hash_diff'
    autoload :Merge, 'archimate/diff/merge'
    autoload :ModelDiff, 'archimate/diff/model_diff'
    autoload :OrganizationDiff, 'archimate/diff/organization_diff'
    autoload :RelationshipDiff, 'archimate/diff/relationship_diff'
    autoload :StringDiff, 'archimate/diff/string_diff'
    autoload :UnorderedListDiff, 'archimate/diff/unordered_list_diff'
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
    Diff::Context.new(local, remote).diffs(Diff::ModelDiff.new)
  end
end
