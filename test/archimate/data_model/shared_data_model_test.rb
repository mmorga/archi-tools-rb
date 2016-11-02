# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class SharedDataModelTest < Minitest::Test
      [
        Bendpoint, Bounds, Child, Color, Diagram, Documentation, Element,
        Folder, Font, Model, Property, Relationship, SourceConnection, Style
      ].each do |klass|
        [:parent, :in_model, :comparison_attributes].each do |method|
          define_method("test_#{klass.to_s.split('::').last.downcase}_has_method_#{method}") do
            assert klass.public_instance_methods.include?(method), "Expected #{klass} to have a method #{method}"
          end
        end

        [:parent_id].each do |attr|
          define_method("test_#{klass.to_s.split('::').last.downcase}_has_attribute_#{attr}") do
            assert klass.public_instance_methods.include?(attr), "Expected #{klass} to have a method #{attr}"
          end
        end

        [DataModel::With].each do |mod|
          define_method("test_#{klass.to_s.split('::').last.downcase}_includes_#{mod}") do
            assert klass.ancestors.include?(mod), "Expected #{klass} to include module #{mod}"
          end
        end
      end
    end
  end
end
