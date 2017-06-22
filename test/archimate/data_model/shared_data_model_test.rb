# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class SharedDataModelTest < Minitest::Test
      [
        Location, Bounds, ViewNode, Color, Diagram, LangString, Documentation, Element,
        Organization, Font, Model, Property, Relationship, Connection, Style
      ].each do |klass|
        [:parent, :in_model].each do |method|
          define_method("test_#{klass.to_s.split('::').last.downcase}_has_method_#{method}") do
            assert klass.public_instance_methods.include?(method), "Expected #{klass} to have a method #{method}"
          end
        end
      end
    end
  end
end
