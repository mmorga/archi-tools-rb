# frozen_string_literal: true
require "archimate/version"
require "nokogiri"
require "highline"
require "dry-types"
require "dry-struct"

HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
  cs[:headline]        = [ :bold, :yellow, :on_black ]
  cs[:horizontal_line] = [ :bold, :white ]
  cs[:even_row]        = [ :green ]
  cs[:odd_row]         = [ :magenta ]
  cs[:error]           = [ :bold, :red ]
  cs[:warning]         = [ :bold, :yellow ]
end

module Archimate
  # The root path for YARD source libraries
  ROOT = File.expand_path(File.dirname(__FILE__))

  require File.join(Archimate::ROOT, 'archimate', 'autoload')
  require File.join(Archimate::ROOT, 'archimate', 'types')

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
