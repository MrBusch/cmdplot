# frozen_string_literal: true

require_relative 'test_helper'

class BrailleTest < Minitest::Test
    def test_char
        assert_equal '⠀', CmdPlot::Braille.char([[false, false]] * 4)
        assert_equal '⣿', CmdPlot::Braille.char([[true, true]] * 4)
        assert_equal '⠁', CmdPlot::Braille.char([[true, false], [false, false], [false, false], [false, false]])
        assert_equal '⢀', CmdPlot::Braille.char([[false, false], [false, false], [false, false], [false, true]])
    end

    def test_line_points
        assert_equal [[0, 0], [1, 1], [2, 2]], CmdPlot::Braille.line_points(0, 0, 2, 2)
        assert_equal [[3, 1], [2, 1], [1, 1]], CmdPlot::Braille.line_points(3, 1, 1, 1)
        assert_equal [[1, 5]], CmdPlot::Braille.line_points(0, nil, 1, 5)
        assert_equal [[0, 5]], CmdPlot::Braille.line_points(0, 5, 1, nil)
        assert_empty CmdPlot::Braille.line_points(0, nil, 1, nil)
    end

    def test_linspace
        assert_equal [0.0, 0.5, 1.0], CmdPlot::Data.linspace(0, 1, 3)
        assert_equal [2.0], CmdPlot::Data.linspace(2, 5, 1)
    end

    def test_no_top_level_constants
        refute defined?(::BasicData)
    end
end
