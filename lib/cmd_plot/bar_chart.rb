# frozen_string_literal: true

class CmdPlot
    # Horizontal bar charts and histograms.
    module BarChart
        # One bar per value, scaled so the largest value fills the width.
        #
        # values - numbers; negative values draw an empty bar
        # labels - one label per value
        # symbol - character the bars are drawn with
        def bar(values, labels, symbol = '°')
            raise ArgumentError, 'nothing to plot: no values' if values.empty?
            raise ArgumentError, 'values and labels must have the same length' if values.length != labels.length

            labels = labels.map(&:to_s)
            max_value = values.max.to_f
            label_width = labels.map(&:length).max
            value_width = values.map { |v| v.to_s.length }.max
            bar_width = @width - label_width - value_width - 3
            buf = +''
            values.zip(labels).each { |value, label|
                length = max_value.positive? ? ((value / max_value) * bar_width).round : 0
                buf << label.rjust(label_width) << ': ' << value.to_s.rjust(value_width) << ' '
                buf << (symbol * [length, 0].max) << "\n"
            }
            out.print(buf)
            nil
        end

        # Counts the values into bins and draws them as a bar chart, labelled with the bin
        # centers.
        #
        # bins - number of equal-width bins, or an array of bin limits
        def histogram(values, bins = 20)
            raise ArgumentError, 'nothing to plot: no values' if values.empty?

            counts, centers = Data.histogram(values, bins)
            bar(counts, centers.map { |c| c.round(1).to_s })
        end
    end

    include BarChart
end
