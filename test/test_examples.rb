# frozen_string_literal: true

module Minitest
  class Test
    # Example file for the Archi tool
    ARCHISURANCE_FILE = File.join(TEST_EXAMPLES_FOLDER, "archisurance.archimate").freeze
    ARCHISURANCE_MODEL_EXCHANGE_FILE = File.join(TEST_EXAMPLES_FOLDER, "archisurance.xml").freeze
    ARCHISURANCE_MODEL_EXCHANGE_30_FILE = File.join(TEST_EXAMPLES_FOLDER, "ArchiSurance V3.xml").freeze

    def archisurance_source
      @@archisurance_source ||= File.read(ARCHISURANCE_FILE).freeze
    end

    def archisurance_model
      # archisurance_model = IceNine.deep_freeze(Archimate.parse(archisurance_source))
      @@archisurance_mode ||= Archimate.parse(archisurance_source).freeze
    end

    # Example model for ArchiMate v 2.1
    def archisurance_model_exchange_source
      @@archisurance_model_exchange_source ||= File.read(ARCHISURANCE_MODEL_EXCHANGE_FILE).freeze
    end

    def model_exchange_archisurance_model
      # model_exchange_archisurance_model = IceNine.deep_freeze(Archimate.parse(archisurance_model_exchange_source))
      @@model_exchange_archisurance_model ||= Archimate.parse(archisurance_model_exchange_source).freeze
    end

    # Example model for ArchiMate v 3.0
    def archisurance_model_exchange_30_source
      @@archisurance_model_exchange_30_source ||= File.read(ARCHISURANCE_MODEL_EXCHANGE_30_FILE).freeze
    end

    def model_exchange_archisurance_30_model
      # model_exchange_archisurance_30_model = IceNine.deep_freeze(Archimate.parse(archisurance_model_exchange_30_source))
      @@model_exchange_archisurance_30_model ||= Archimate.parse(archisurance_model_exchange_30_source).freeze
    end
  end
end
