# frozen_string_literal: true

require 'date'

# Quick text-mode plots, charts and tables for the console.
#
#   plotter = CmdPlot.new(100, 25)
#   plotter.plot([1, 4, 9, 16, 25])
#   plotter.bar([3, 5, 2], %w[a b c])
#   plotter.table([{ 'id' => 1, 'name' => 'x' }])
#
# Every method writes to the output stream and returns nil, so it reads cleanly in an
# interactive console.
class CmdPlot
    # ANSI color numbers: red, green, brown, blue, magenta, cyan, gray
    TEXT_COLORS = [1, 2, 3, 4, 5, 6, 7].freeze
    FILL_SYMBOLS = ['█', '▓', '░', '▒'].freeze

    attr_reader :width, :height

    # width  - width of the drawing area in characters
    # height - height of the drawing area in lines
    # out:   - IO to write to; defaults to whatever $stdout is at the time of the call
    # color: - false drops the ANSI escape codes, e.g. when writing to a file
    def initialize(width = 140, height = 40, out: nil, color: true)
        raise ArgumentError, 'width must be at least 1' if width.to_i < 1
        raise ArgumentError, 'height must be at least 1' if height.to_i < 1

        @width = width.to_i
        @height = height.to_i
        @out = out
        @color = color
    end

    private

    def out
        @out || $stdout
    end

    def color?
        @color
    end

    def colorize(text, code)
        color? ? "\e[#{code}m#{text}\e[0m" : text
    end
end

require 'cmd_plot/version'
require 'cmd_plot/data'
require 'cmd_plot/braille'
require 'cmd_plot/line_plot'
require 'cmd_plot/bar_chart'
require 'cmd_plot/color_map'
require 'cmd_plot/tables'
require 'cmd_plot/legacy'
