module Archimate
  module Model
    class Organization
      attr_reader :folders

      def initialize(folders)
        @folders = folders
      end
    end
  end
end
