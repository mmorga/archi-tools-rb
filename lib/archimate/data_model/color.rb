# frozen_string_literal: true
module Archimate
  module DataModel
    class Color < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :r, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :g, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :b, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :a, Coercible::Int.constrained(lt: 101, gt: -1)

      def comparison_attributes
        [:@r, :@g, :@b, :@a]
      end

      def to_s
        "Color(r: #{r}, g: #{g}, b: #{b}, a: #{a})"
      end
    end

    Dry::Types.register_class(Color)
    OptionalColor = Color.optional

    # TODO: create functions to format and convert
  end
end
