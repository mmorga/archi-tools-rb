# frozen_string_literal: true

require "highline"

module Archimate
  module Cli
    class ConflictResolver
      def initialize
        @config = Config.instance
        # TODO: pull the stdin/stdout from the app config
        @hl = HighLine.new(STDIN, STDOUT)
      end

      # TODO: this implementation has much to be written
      def resolve(conflict)
        return [] unless @config.interactive
        base_local_diffs = conflict.base_local_diffs
        base_remote_diffs = conflict.base_remote_diffs
        choice = @hl.choose do |menu|
          menu.prompt = conflict
          menu.choice(:local, text: base_local_diffs.map(&:to_s).join("\n\t\t"))
          menu.choice(:remote, text: base_remote_diffs.map(&:to_s).join("\n\t\t"))
          # menu.choice(:neither, help: "Don't choose either set of diffs")
          # menu.choice(:edit, help: "Edit the diffs (coming soon)")
          # menu.choice(:quit, help: "I'm in over my head. Just stop!")
          menu.select_by = :index_or_name
        end
        case choice
        when :local
          base_local_diffs
        when :remote
          base_remote_diffs
        else
          error "Unexpected choice #{choice.inspect}."
        end
      end
    end
  end
end
