# frozen_string_literal: true
module Archimate
  module Svg
    module StringRefinements
      module StringRefinementsMethods
        class String
          def to_css_class
            gsub(/::/, '/')
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2')
              .gsub(/([a-z\d])([A-Z])/, '\1-\2')
              .downcase
          end
        end
      end

      refine String do
        include StringRefinementsMethods
      end
    end
  end
end
