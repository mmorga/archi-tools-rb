# frozen_string_literal: true

module Archimate
  module DataModel
    LabelGroup = Strict::Array.member(LangString).default([])
  end
end
