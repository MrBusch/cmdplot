class CmdPlot::Plot
    def initialize(width = 140, height = 40, symbol = '°')
        @width = width
        @height = height
        @symbol = symbol
    end

    def plot(x, y = nil)
        # If only one parameter is given treat it as the y-axis data and fill up x automatically
        if y.nil?
            y = x
            x = BasicData::linspace(0.0, y.length, y.length)
        end
        # Scale x axis to the desired console resolution
        x_max = x.compact.max
        x_min = x.compact.min
        if x_min == x_max
            x_min = x_min - 0.1
            x_max = x_max + 0.1
        end
        x = x.map { |v| v.nil? ? nil : ((v - x_min) / (x_max - x_min).to_f * (@width - 1)).round }
        # Scale y axis to the desired console resolution
        y_max = y.compact.max
        y_min = y.compact.min
        if y_min == y_max
            y_min = y_min - 0.1
            y_max = y_max + 0.1
        end
        y = y.map { |v| v.nil? ? nil : ((v - y_min) / (y_max - y_min).to_f * (@height - 1)).round }

        # Full plot-picture starts out empty
        picture = Array.new(@height) { Array.new(@width) {' '} }
        # Run through all the points of the curve and fill in the plotting symbol
        for point in x.zip(y)
            next if point[1].nil? || point[0].nil?
            picture[@height - 1 - point[1]][point[0]] = @symbol
        end

        # X-axis
        x_ticks = BasicData::linspace(x_min, x_max, [2, @width / 15].max).map { |v|
            tick_to_display(v)
        }
        # Y-axis
        y_ticks = BasicData::linspace(y_max, y_min, [2, @height / 10].max).map { |v|
            tick_to_display(v)
        }
        y_tick_width = y_ticks.map { |e| e.length }.max
        y_tick_spacing = (@height - y_ticks.length) / (y_ticks.length - 1)
        missing = @height - (y_tick_spacing * (y_ticks.length - 1) + y_ticks.length)
        missing_dist = missing == 0 ? @height : y_ticks.length / missing.to_f

        # Print the y-axis and plot picture
        row = 0
        next_tick = 0
        tick_offset = 0
        for line in picture
            if row == (tick_offset + next_tick * (y_tick_spacing + 1))
                print ' ' * (y_tick_width - y_ticks[next_tick].length)
                print y_ticks[next_tick] + ' ├ '
                next_tick += 1
                tick_offset += 1 if ((tick_offset + 1) * missing_dist) < (next_tick + 2)
            else
                print ' ' * y_tick_width + ' │ '
            end
            puts line.join
            row += 1
        end

        # Print x-axis
        x_tick_spacing = (@width - x_ticks.length) / (x_ticks.length - 1)
        missing = @width - (x_tick_spacing * (x_ticks.length - 1) + x_ticks.length)
        missing_dist = missing == 0 ? @width : x_ticks.length / missing.to_f
        print ' ' * y_tick_width + ' └─'
        next_tick = 0
        added_space = 0
        for tick in x_ticks
            if tick == x_ticks[-1]
                puts '┴'
            else
                print '┴'
                print '─' * x_tick_spacing
                next_tick += 1
                if ((added_space + 1) * missing_dist) < (next_tick + 2)
                    added_space += 1
                    print '─'
                end
            end
        end

        # Print x labels
        total_label_length = x_ticks.map(&:length).inject(:+)
        x_tick_label_spacing = (@width - total_label_length) / (x_ticks.length - 1)
        missing = @width - (x_tick_label_spacing * (x_ticks.length - 1) + total_label_length)
        missing_dist = missing == 0 ? @width : x_ticks.length / missing.to_f
        print ' ' * y_tick_width + '   '
        next_tick = 0
        added_space = 0
        for tick in x_ticks
            if tick == x_ticks[-1]
                puts tick
            else
                print tick
                print ' ' * x_tick_label_spacing
                next_tick += 1
                if ((added_space + 1) * missing_dist) < (next_tick + 2)
                    added_space += 1
                    print ' '
                end
            end
        end
        return nil
    end

    def tick_to_display(v)
        s = v.to_s
        dot = s.index('.')
        dot = s.length - 1 if dot.nil?
        if dot == 1 && s[0] == '0'
            for dot in 1..(s.length - 1)
                next if s[dot + 1] == '0' || s[dot + 1] == '.'
                break
            end
        end
        s[0..(dot+2)]
    end
end
