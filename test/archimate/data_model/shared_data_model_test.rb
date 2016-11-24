# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class SharedDataModelTest < Minitest::Test
      [
        Bendpoint, Bounds, Child, Color, Diagram, Documentation, Element,
        Folder, Font, Model, Property, Relationship, SourceConnection, Style
      ].each do |klass|
        [:parent, :in_model].each do |method|
          define_method("test_#{klass.to_s.split('::').last.downcase}_has_method_#{method}") do
            assert klass.public_instance_methods.include?(method), "Expected #{klass} to have a method #{method}"
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
