# frozen_string_literal: true
# @private
def __p(path)
  File.join(Archimate::ROOT, 'archimate', *path.split('/'))
end

module Archimate
  module Cli
    autoload :Archi, __p('cli/archi')
    autoload :Cleanup, __p('cli/cleanup')
    autoload :Convert, __p('cli/convert')
    autoload :Diff, __p('cli/diff')
    autoload :Duper, __p('cli/duper')
    autoload :Mapper, __p('cli/mapper')
    autoload :Merger, __p('cli/merger')
    autoload :Projector, __p('cli/projector')
    autoload :Svger, __p('cli/svger')
    autoload :XmlTextconv, __p('cli/xml_textconv')
  end

  module Conversion
    autoload :ArchiFileFormat, __p('conversion/archi_file_format')
    autoload :ModelExchangeFileFormat, __p('conversion/model_exchange_file_format')
    autoload :ArchiToMeff, __p('conversion/archi_to_meff')
    autoload :Quads, __p('conversion/quads')
    autoload :GraphML, __p('conversion/graph_ml')
  end

  module Diff
    autoload :Context, __p('diff/context')
    autoload :Difference, __p('diff/difference')
    autoload :ElementDiff, __p('diff/element_diff')
    autoload :IdHashDiff, __p('diff/id_hash_diff')
    autoload :Merge, __p('diff/merge')
    autoload :ModelDiff, __p('diff/model_diff')
    autoload :RelationshipDiff, __p('diff/relationship_diff')
    autoload :StringDiff, __p('diff/string_diff')
    autoload :UnorderedListDiff, __p('diff/unordered_list_diff')
  end

  module Model
    autoload :Bounds, __p('model/bounds')
    autoload :Child, __p('model/child')
    autoload :Diagram, __p('model/diagram')
    autoload :Element, __p('model/element')
    autoload :Folder, __p('model/folder')
    autoload :Model, __p('model/model')
    autoload :Property, __p('model/property')
    autoload :PropertyList, __p('model/property_list')
    autoload :Relationship, __p('model/relationship')
  end

  autoload :ArchiFileReader, __p('archi_file_reader')
  autoload :Diff, __p('diff')
  autoload :Document, __p('document')
  autoload :ErrorHelper, __p('error_helper')
  autoload :MaybeIO, __p('maybe_io')
  autoload :OutputIO, __p('output_io')
end

undef __p
