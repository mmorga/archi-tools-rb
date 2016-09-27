module Archimate
  module Model
    class Bendpoint < Dry::Struct::Value
      attribute :start_x, Archimate::Model::Coercible::Float.optional
      attribute :start_y, Archimate::Model::Coercible::Float.optional
      attribute :end_x, Archimate::Model::Coercible::Float.optional
      attribute :end_y, Archimate::Model::Coercible::Float.optional
    end
  end
end
