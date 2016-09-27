module Archimate
  module Model
    class Bounds < Dry::Struct::Value
      attribute :x, Archimate::Model::Coercible::Float.optional
      attribute :y, Archimate::Model::Coercible::Float.optional
      attribute :width, Archimate::Model::Coercible::Float
      attribute :height, Archimate::Model::Coercible::Float
    end
  end
end
