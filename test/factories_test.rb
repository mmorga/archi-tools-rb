# frozen_string_literal: true
require 'test_helper'

class FactoriesTest < Minitest::Test
  using Archimate::DataModel::DiffableArray
  using Archimate::DataModel::DiffablePrimitive

  def test_model_assignment_on_creation
    base = build_model(
      diagrams: [
        build_diagram(
          children: [
            build_view_node(
              connections: [
                build_connection(
                  bendpoints: (1..3).map { build_location }
                )
              ]
            )
          ]
        )
      ]
    )

    assert_equal base, base.diagrams.in_model
    base.diagrams.each do |diagram|
    	assert_equal base, diagram.in_model
    	assert_equal base, diagram.nodes.in_model
    	diagram.nodes.each do |child|
	    	assert_equal base, child.in_model
	    	assert_equal base, child.connections.in_model
	    	child.connections.each do |connection|
		    	assert_equal base, connection.in_model
		    	assert_equal base, connection.bendpoints.in_model
		    	connection.bendpoints.each do |bendpoint|
			    	assert_equal base, bendpoint.in_model
			    end
			  end
			end
    end
  end

  def test_build_model_with_validate_model
    model = build_model(with_elements: 3)

    validate_model_refs(model, model)
  end

  private

  def validate_model_refs(node, model)
    return if node.primitive?
    raise "Invalid in_model value: '#{node.in_model}' parent: '#{node.parent}' for #{node.class} at path #{node.path}" if node.in_model.nil? && !node.is_a?(Archimate::DataModel::Model)
    case node
    when Archimate::DataModel::ArchimateNode
      node.struct_instance_variables.each do |attr|
        validate_model_refs(node[attr], model)
      end
    when Array
      node.each_with_index do |val, idx|
        validate_model_refs(val, model)
      end
    end
  end
end
