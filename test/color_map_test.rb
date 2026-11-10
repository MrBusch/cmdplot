# frozen_string_literal: true

require_relative 'test_helper'

class ColorMapTest < Minitest::Test
    include PlotHelpers

    def test_pcolor_scales_to_size
        text = render(4, 2) { |p| p.pcolor([[0, 0, 1, 1], [0, 0, 1, 1], [2, 2, 3, 3], [2, 2, 3, 3]]) }
        header, *rows = text.lines.map(&:chomp)
        assert_equal 'Pcolor with x_scale: 1.0, y_scale: 2.0, z_min: 0, z_max: 3', header
        assert_equal 2, rows.length
        assert(rows.all? { |r| r.length == 4 })
    end

    def test_pcolor_colors
        io = StringIO.new
        CmdPlot.new(2, 1, out: io).pcolor([[0, 1]], 2)
        assert_equal "\e[31m█\e[0m\e[32m█\e[0m\n", io.string.lines.last
    end

    def test_pcolor_constant_data
        text = render(2, 2) { |p| p.pcolor([[5, 5], [5, 5]]) }
        assert_equal "██\n██\n", text.lines.drop(1).join
    end

    def test_pcolor_needs_data
        assert_raises(ArgumentError) { render { |p| p.pcolor([]) } }
    end
end
