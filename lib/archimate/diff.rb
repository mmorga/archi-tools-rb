# frozen_string_literal: true
module Archimate
  module Diff
    def self.parent_for_node_type(node, doc)
      doc.at_xpath(ELEMENT_TYPE_TO_PARENT_XPATH[node["xsi:type"]])
    end

    def self.add_node_to_doc(node, doc)
      parent_for_node_type(node, doc) << node
    end
  end
end
