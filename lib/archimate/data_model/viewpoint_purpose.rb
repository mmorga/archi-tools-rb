# frozen_string_literal: true

module Archimate
  module DataModel
    ViewpointPurposeEnum = Strict::String.enum(%w[Designing Deciding Informing])
    ViewpointPurpose = Strict::Array.member(ViewpointPurposeEnum).default([])
  end
end
