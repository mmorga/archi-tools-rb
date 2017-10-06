# frozen_string_literal: true

require "highline"

HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
  cs[:headline]                       = %i[underline bold yellow on_black]
  cs[:horizontal_line]                = %i[bold white]
  cs[:even_row]                       = [:green]
  cs[:odd_row]                        = [:magenta]
  cs[:error]                          = %i[bold red]
  cs[:warning]                        = %i[bold yellow]
  cs[:debug]                          = [:gray]
  cs[:insert]                         = %i[bold green]
  cs[:change]                         = %i[bold yellow]
  cs[:move]                           = %i[bold yellow]
  cs[:delete]                         = %i[bold red]
  cs[:Business]                       = %i[black on_light_yellow]
  cs[:Application]                    = %i[black on_light_blue]
  cs[:Technology]                     = %i[black on_light_green]
  cs[:Motivation]                     = %i[black on_light_magenta]
  cs[:"Implementation and Migration"] = %i[black on_light_red]
  cs[:Physical]                       = %i[black on_light_green]
  cs[:Connectors]                     = %i[black on_light_gray]
  cs[:unknown_layer]                  = %i[black on_gray]
  cs[:Model]                          = [:cyan]
  cs[:Connection]               = [:blue]
  cs[:Organization]                   = [:cyan]
  cs[:Relationship]                   = %i[black on_light_gray]
  cs[:Diagram]                        = %i[black on_cyan]
  cs[:path]                           = [:light_blue]
end

module Archimate
  class Color
    def self.layer_color(layer, str)
      layer_sym = layer.to_sym
      sym = HighLine.color_scheme.include?(layer_sym) ? layer_sym : :unknown_layer
      color(str, sym)
    end

    def self.data_model(str)
      layer_color(str, str)
    end

    def self.color(str, args)
      HighLine.color(str, args)
    end

    def self.uncolor(str)
      HighLine.uncolor(str)
    end
  end
end
