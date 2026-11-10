# frozen_string_literal: true

require_relative 'test_helper'

# The 0.0.1 API still works.
class LegacyTest < Minitest::Test
    def test_plot
        out, = capture_io { CmdPlot::Plot.new(30, 6).plot([1, 2, 3], [3, 1, 2]) }
        assert_includes out, '3.00'
    end

    def test_bar_and_histogram
        out, = capture_io { CmdPlot::Bar.new(20, 5, '*').bar([1, 2], %w[a b]) }
        assert_includes out, 'b: 2 *'
        out, = capture_io { CmdPlot::Bar.new(20, 5).histogram([1, 2, 2, 3], 2) }
        assert_equal 2, out.lines.length
    end

    def test_pcolor
        out, = capture_io { CmdPlot::Pcolor.new(4, 2).pcolor([[1, 2], [3, 4]]) }
        assert_equal 3, out.lines.length
    end
end
