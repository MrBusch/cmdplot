class CmdPlot::Bar
    def initialize(width = 140, height = 40, symbol = '°')
        @width = width
        @height = height
        @symbol = symbol
    end

    def bar(height, labels)
        # Calculate scaling of data to plot
        max_height = height.max.to_f
        max_label_length = labels.map { |l| l.length }.max
        max_val_length = height.map { |l| l.to_s.length }.max
        max_bar_length = (@width - max_label_length - max_val_length - 3)
        # Plot each bar
        for data in height.zip(labels)
            label_fill_space = ' ' * (max_label_length - data[1].length)
            value_fill_space = ' ' * (max_val_length - data[0].to_s.length)
            bar_plot = @symbol * ((data[0] / max_height) * max_bar_length).round
            puts "#{label_fill_space}#{data[1]}: #{value_fill_space}#{data[0]} #{bar_plot}"
        end
        return nil
    end

    def histogram(data, bins = 20)
        # Turn data into bins with counts
        counts, bin_centers = BasicData.build_hist(data, bins)
        # Plot as bar chart
        bar(counts, bin_centers.map { |p| p.round(1).to_s })
    end
end
