# frozen_string_literal: true
module Archimate
  module StringExtensions
    def self.included(base)
      base.class_eval do
        undef :underscore if method_defined? :underscore
        def underscore
          gsub(/::/, '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("-", "_")
            .downcase
        end
      end
    end
  end

  def self.extend_strings
    ::String.send(:include, StringExtensions)
  end
end
