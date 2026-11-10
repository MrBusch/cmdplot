# frozen_string_literal: true

require_relative 'test_helper'

class BarChartTest < Minitest::Test
    include PlotHelpers

    def test_bar
        expected = <<~BARS
            alpha:  3 °°°°°°°°°°
                b: 10 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
              ccc:  0 
        BARS
        assert_equal expected, render(43) { |p| p.bar([3, 10, 0], %w[alpha b ccc]) }
    end

    def test_bar_symbol_and_non_string_labels
        assert_equal "1: 2 ##\n2: 4 ####\n", render(9) { |p| p.bar([2, 4], [1, 2], '#') }
    end

    def test_bar_all_zero_or_negative
        assert_equal "a:  0 \nb: -1 \n", render(20) { |p| p.bar([0, -1], %w[a b]) }
    end

    def test_bar_argument_errors
        assert_raises(ArgumentError) { render { |p| p.bar([], []) } }
        assert_raises(ArgumentError) { render { |p| p.bar([1, 2], %w[a]) } }
    end

    def test_histogram
        text = render(30) { |p| p.histogram([1, 1, 2, 3, 3, 3, 4], 3) }
        assert_equal ['1.5: 2', '2.5: 1', '3.5: 4'], text.lines.map { |l| l[0, 6] }
    end

    def test_histogram_with_limits
        text = render(30) { |p| p.histogram([-10, 1, 2, 7, 50], [0, 5, 10]) }
        # Values outside the limits land in the first and last bin.
        assert_equal ['2.5: 3', '7.5: 2'], text.lines.map { |l| l[0, 6] }
    end

    def test_histogram_needs_values
        assert_raises(ArgumentError) { render { |p| p.histogram([]) } }
    end
end
