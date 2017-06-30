# frozen_string_literal: true

module Minitest
  class Test
    # Example file for the Archi tool
    ARCHISURANCE_FILE = File.join(TEST_EXAMPLES_FOLDER, "archisurance.archimate").freeze
    ARCHISURANCE_SOURCE = File.read(ARCHISURANCE_FILE).freeze
    ARCHISURANCE_MODEL = IceNine.deep_freeze(Archimate.parse(ARCHISURANCE_SOURCE))

    # Example model for ArchiMate v 2.1
    ARCHISURANCE_MODEL_EXCHANGE_FILE = File.join(TEST_EXAMPLES_FOLDER, "archisurance.xml").freeze
    ARCHISURANCE_MODEL_EXCHANGE_SOURCE = File.read(ARCHISURANCE_MODEL_EXCHANGE_FILE).freeze
    MODEL_EXCHANGE_ARCHISURANCE_MODEL = IceNine.deep_freeze(Archimate.parse(ARCHISURANCE_MODEL_EXCHANGE_SOURCE))

    # Example model for ArchiMate v 3.0
    ARCHISURANCE_MODEL_EXCHANGE_30_FILE = File.join(TEST_EXAMPLES_FOLDER, "ArchiSurance V3.xml").freeze
    ARCHISURANCE_MODEL_EXCHANGE_30_SOURCE = File.read(ARCHISURANCE_MODEL_EXCHANGE_30_FILE).freeze
    MODEL_EXCHANGE_ARCHISURANCE_30_MODEL = IceNine.deep_freeze(Archimate.parse(ARCHISURANCE_MODEL_EXCHANGE_30_SOURCE))
  end
end
