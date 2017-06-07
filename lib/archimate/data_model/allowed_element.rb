# frozen_string_literal: true

module Archimate
  module DataModel
    ViewpointContentEnum = Strict::String.enum(%w[Details Coherence Overview])
    ViewpointContent = Strict::Array.member(ViewpointContentEnum).default([])
  end
end
