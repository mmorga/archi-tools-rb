# frozen_string_literal: true
module Archimate
  module Svg
    class ScaledPath
      PathCmd = Struct.new(:cmd, :args)

      def initialize(d, bounds)
        @d = d
        @bounds = bounds
        @xscale = ScaledValue.new(120, @bounds.width)
        @yscale = ScaledValue.new(60, @bounds.height)
      end

      def d
        path_cmds.join(" ")
      end

      # Takes the set of points (d) for a path and scales it to the bounds given
      # probably needs to be moved to its own class
      def path_cmds
        path_cmds = split_path(@d)
        path_cmds.map do |pcmd|
          case pcmd.cmd
          when "M"
            "M #{@bounds.left} #{@bounds.top}"
          when "m"
            "m #{@xscale.scale(pcmd.args[0])} #{@yscale.scale(pcmd.args[1])}"
          when "l"
            "l #{@xscale.scale(pcmd.args[0])} #{@yscale.scale(pcmd.args[1])}"
          when "h"
            "h #{@xscale.scale(pcmd.args[0])}"
          when "v"
            "v #{@yscale.scale(pcmd.args[0])}"
          when "c"
            "c #{pcmd.args.join(" ")}"
          when "Z", "z"
            "z"
          when "a"
            [
              "a",
              @xscale.scale(pcmd.args[0]),
              @yscale.scale(pcmd.args[1]),
              pcmd.args[2].to_i,
              pcmd.args[3].to_i,
              pcmd.args[4].to_i,
              @xscale.scale(pcmd.args[5]),
              @yscale.scale(pcmd.args[6])
            ].join(" ")
          else
            raise ArgumentError, "Unhandled path command type #{pcmd.cmd.inspect}"
          end
        end
      end

      def split_path(d)
        path_cmds = []
        path_ary = d.split(/([a-zA-Z])/).map { |s1| s1.split(/[\s,]+/) }.flatten.reject(&:empty?)
        until path_ary.empty?
          cmd = path_ary.shift
          args = path_ary.take_while { |i| i =~ /\-?\d+\.?\d*/ }.map(&:to_f)
          path_cmds << PathCmd.new(cmd, args)
          path_ary.shift(args.size)
        end
        path_cmds
      end
    end
  end
end
