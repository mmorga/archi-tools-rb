module Archimate
  module ErrorHelper
    def error(msg)
      Highline.say("#{colors('Error:', :error)} #{msg}")
    end

    def warning(msg)
      Highline.say("#{colors('Warning:', :warning)} #{msg}")
    end

    def info(msg)
      Highline.say(msg)
    end
  end
end
