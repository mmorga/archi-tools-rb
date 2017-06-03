module Minitest
  class Test
    TEST_AIO = Archimate::AIO.new(interactive: false, output_io: StringIO.new, messages_io: StringIO.new)
    ARCHISURANCE_FILE = File.join(TEST_EXAMPLES_FOLDER, "archisurance.archimate").freeze
    ARCHISURANCE_SOURCE = File.read(ARCHISURANCE_FILE).freeze
    ARCHISURANCE_MODEL = IceNine.deep_freeze(Archimate.parse(ARCHISURANCE_SOURCE))
    ARCHISURANCE_MODEL_EXCHANGE_FILE = File.join(TEST_EXAMPLES_FOLDER, "archisurance.xml").freeze
    ARCHISURANCE_MODEL_EXCHANGE_SOURCE = File.read(ARCHISURANCE_MODEL_EXCHANGE_FILE).freeze
    MODEL_EXCHANGE_ARCHISURANCE_MODEL = IceNine.deep_freeze(
      Archimate::FileFormats::ModelExchangeFileReader.parse(
        ARCHISURANCE_MODEL_EXCHANGE_SOURCE
      )
    )
  end
end
