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
  end

  module Conversion
    autoload :ArchiToMeff, __p('conversion/archi_to_meff')
    autoload :Quads, __p('conversion/quads')
  end

  module Diff
    autoload :Change, __p('diff/change')
    autoload :Diagram, __p('diff/diagram')
    autoload :DocumentationList, __p('diff/documentation_list')
    autoload :Element, __p('diff/element')
    autoload :Folder, __p('diff/folder')
    autoload :Model, __p('diff/model')
    autoload :PropertyList, __p('diff/property_list')
    autoload :Relation, __p('diff/relation')
  end

  autoload :Diff, __p('diff')
  autoload :Document, __p('document')
  autoload :ErrorHelper, __p('error_helper')
  autoload :MaybeIO, __p('maybe_io')
end

undef __p
