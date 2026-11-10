# frozen_string_literal: true

require_relative 'test_helper'

class LinePlotTest < Minitest::Test
    include PlotHelpers

    def lines(text)
        text.lines.map(&:rstrip)
    end

    def test_y_values_only
        expected = <<~PLOT
            5.00 ├                                       ⡠⠊
                 │                                    ⢀⠔⠉
                 │                                  ⣀⠔⠁
                 │              ⣀                 ⡠⠊
                 │          ⢀⡠⠒⠉ ⠉⠉⠒⠢⠤⣀⣀       ⢀⡠⠊
                 │       ⢀⠤⠒⠁           ⠉⠑⠒⠤⠤⣀⠔⠁
                 │    ⣀⠔⠊⠁
            1.00 ├ ⡠⠔⠊
                 └─┴──────────────────────────────────────┴
                   0.00                                3.00
        PLOT
        assert_equal lines(expected), lines(render { |p| p.plot([1, 3, 2, 5]) })
    end

    def test_x_and_y_arrays_match_hash
        x = [0, 1, 2, 3]
        y = [1, 3, 2, 5]
        assert_equal render { |p| p.plot(x.zip(y).to_h) }, render { |p| p.plot(x, y) }
        assert_equal render { |p| p.plot(y) }, render { |p| p.plot(x, y) }
    end

    def test_returns_nil
        assert_nil CmdPlot.new(20, 4, out: StringIO.new).plot([1, 2])
    end

    def test_colors_each_series
        io = StringIO.new
        CmdPlot.new(40, 8, out: io).plot([{ 0 => 0, 1 => 1 }, { 0 => 1, 1 => 0 }])
        assert_includes io.string, "\e[1;91m"
        assert_includes io.string, "\e[1;92m"

        io = StringIO.new
        CmdPlot.new(40, 8, out: io).plot([0, 1], intense: false, bold: false)
        assert_includes io.string, "\e[0;31m"
    end

    def test_writes_to_stdout_by_default
        out, = capture_io { CmdPlot.new(20, 4).plot([1, 2]) }
        assert_includes out, '2.00'
    end

    def test_date_axis
        start = Date.new(2024, 1, 1)
        text = render(60, 10) { |p| p.plot((0..30).map { |i| [start + i, i] }.to_h) }
        assert_includes text, '2024-01-01'
        assert_includes text, '2024-01-31'
    end

    def test_date_series_with_different_starts_share_one_axis
        start = Date.new(2024, 1, 1)
        early = { start => 1, start + 10 => 1 }
        late = { start + 20 => 2, start + 30 => 2 }
        text = render(40, 8) { |p| p.plot([early, late]) }
        rows = text.lines
        top = rows.first
        bottom = rows[7]
        # The late series sits in the right half, the early one in the left half.
        assert_match(/\A *2\.\d\d ├ {20,}\S/, top)
        assert_match(/\A *1\.\d\d ├ \S/, bottom)
        assert_includes text, '2024-01-31'
    end

    def test_mixing_dates_and_numbers_raises
        assert_raises(ArgumentError) { render { |p| p.plot([{ Date.new(2024, 1, 1) => 1 }, { 1 => 2 }]) } }
    end

    def test_constant_series
        assert_includes render { |p| p.plot([5, 5, 5]) }, '5.25'
        assert_includes render { |p| p.plot([0, 0, 0]) }, '1.00'
        neg = render { |p| p.plot([-4, -4]) }
        assert_includes neg, '-3.80'
        assert_includes neg, '-4.20'
    end

    def plot_area(text, height)
        text.lines.first(height).map { |l| l.split(/[│├] /, 2).last.chomp }
    end

    def test_single_point_is_drawn
        area = plot_area(render { |p| p.plot({ 3 => 7 }) }, 8)
        assert_equal 1, area.join.count('^ ')
    end

    def test_nil_values_leave_gaps
        area = plot_area(render(40, 4) { |p| p.plot([1, 1, nil, nil, nil, nil, nil, 1, 1]) }, 4)
        row = area.find { |r| r.match?(/\S/) }
        assert_match(/\A\S+ {20,}\S+ *\z/, row)
    end

    def test_all_nil_raises
        assert_raises(ArgumentError) { render { |p| p.plot([nil, nil]) } }
    end

    def test_rejects_unknown_input
        assert_raises(ArgumentError) { render { |p| p.plot(%w[a b]) } }
        assert_raises(ArgumentError) { render { |p| p.plot('abc') } }
    end

    def test_rejects_tiny_sizes
        assert_raises(ArgumentError) { CmdPlot.new(0, 10) }
        assert_raises(ArgumentError) { render(10, 1) { |p| p.plot([1, 2]) } }
    end
end
