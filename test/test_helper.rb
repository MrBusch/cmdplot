# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'cmd_plot'
require 'stringio'
require 'minitest/autorun'

module PlotHelpers
    # Renders without colors into a string.
    def render(width = 40, height = 8, &block)
        io = StringIO.new
        block.call(CmdPlot.new(width, height, out: io, color: false))
        io.string
    end
end
