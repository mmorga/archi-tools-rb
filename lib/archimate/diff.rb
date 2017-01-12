# frozen_string_literal: true
module Archimate
  module Diff
    require 'archimate/diff/difference'
    require 'archimate/diff/archimate_node_reference'
    require 'archimate/diff/archimate_identified_node_reference'
    require 'archimate/diff/archimate_array_reference'
    require 'archimate/diff/archimate_node_attribute_reference'
    require 'archimate/diff/change'
    require 'archimate/diff/conflict'
    require 'archimate/diff/conflicts'
    require 'archimate/diff/delete'
    require 'archimate/diff/insert'
    require 'archimate/diff/merge'
    require 'archimate/diff/move'
  end
end
