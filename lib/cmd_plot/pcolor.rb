class CmdPlot::Pcolor

    #red, green, brown, blue, magenta, cyan, gray
    TEXT_COLORS = [31, 32, 33, 34, 35, 36, 37]
    FILL_SYMBOLS = ['░', '▒', '▓', '█']
    MAX_SHADES = TEXT_COLORS.length * FILL_SYMBOLS.length

    def initialize(width = 140, height = 40)
        @width = width
        @height = height
    end

    def pcolor(data, shades = nil)
        # Calculate scaling of data to picture
        shades = data.flatten.uniq.length if shades.nil?
        shades = MAX_SHADES if shades > MAX_SHADES or shades <= 0
        x_scale = data[0].length / @width.to_f
        y_scale = data.length / @height.to_f
        z_max = data.map { |r| r.max }.max
        z_min = data.map { |r| r.min }.min
        puts "x_scale: #{x_scale}, y_scale: #{y_scale}, z_min: #{z_min}, z_max: #{z_max}"

        # Calculcate scaled data
        scaled_data = Array.new(@height) { Array.new(@width) { 0.0 } }
        for row in 0..(scaled_data.length - 1)
            for col in 0..(scaled_data[row].length - 1)
                n = 0.0
                lower_row_idx = (row * y_scale).floor
                upper_row_idx = [lower_row_idx, ((row + 1) * y_scale).floor - 1].max
                lower_col_idx = (col * x_scale).floor
                upper_col_idx = [lower_col_idx, ((col + 1) * x_scale).floor - 1].max
                for d_row in lower_row_idx..upper_row_idx
                    for d_col in lower_col_idx..upper_col_idx
                        scaled_data[row][col] += data[d_row][d_col]
                        n += 1.0
                    end
                end
                if(n > 0)
                    scaled_data[row][col] /= n
                else
                    scaled_data[row][col] = nil
                end
            end
        end

        # Full picture starts out empty
        pic = Array.new(@height) { Array.new(@width) { nil } }
        # Run through data and fill in the plotting symbol/color
        for row in 0..(scaled_data.length - 1)
            for col in 0..(scaled_data[row].length - 1)
                val = scaled_data[row][col]
                next if val.nil?
                fill = ((val - z_min) / (z_max - z_min).to_f * (shades - 1)).round
                pic[row][col] = fill
            end
        end

        # Plot the picture
        for row in pic
            for col in row
                if col.nil?
                    print ' '
                else
                    color = TEXT_COLORS[col % TEXT_COLORS.length]
                    sym = FILL_SYMBOLS[col / TEXT_COLORS.length]
                    print "\e[#{color}m#{sym}\e[0m"
                end
            end
            print "\n"
        end
        return nil
    end
end
