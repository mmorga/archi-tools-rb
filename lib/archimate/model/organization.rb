module Archimate
  module Model
    class Organization
      attr_reader :folders

      def initialize(folders)
        @folders = folders
      end

      def dup
        Organization.new(@folders.dup)
      end

      def ==(other)
        @folders == other.folders
      end

      def hash
        self.class.hash ^
          @folders.hash
      end

      def add_folder(folder)
        @folders[folder.id] = folder
      end
    end
  end
end
