# frozen_string_literal: true

module Archimate
  module DataModel
    # This is a Stakeholder of a Concern.
    class Stakeholder < LangString
    end

    Dry::Types.register_class(Stakeholder)
    Stakeholders = Strict::Array.member(Stakeholder).default([])
  end
end
