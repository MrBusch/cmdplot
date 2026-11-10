# frozen_string_literal: true

class CmdPlot
    # 2D color maps of a matrix, e.g. to eyeball a function of two variables.
    module ColorMap
        MAX_SHADES = TEXT_COLORS.length * FILL_SYMBOLS.length

        # data   - array of rows, each an array of numbers
        # shades - number of distinct shades (default: one per distinct value, at most 28)
        #
        # The matrix is averaged down (or stretched up) to the plot size. Each shade is a
        # combination of a color and a fill symbol.
        def pcolor(data, shades = nil)
            raise ArgumentError, 'nothing to plot: no rows' if data.empty? || data.first.empty?

            shades = data.flatten.uniq.length if shades.nil?
            shades = MAX_SHADES if shades > MAX_SHADES || shades <= 0
            x_scale = data.first.length / @width.to_f
            y_scale = data.length / @height.to_f
            z_min, z_max = data.flatten.minmax
            buf = +"Pcolor with x_scale: #{x_scale.round(3)}, y_scale: #{y_scale.round(3)}, " \
                   "z_min: #{z_min.round(3)}, z_max: #{z_max.round(3)}\n"

            Array.new(@height) { |row|
                Array.new(@width) { |col|
                    val = cell_average(data, row, col, x_scale, y_scale)
                    next ' ' if val.nil?

                    shade = z_max == z_min ? 0 : ((val - z_min) / (z_max - z_min).to_f * (shades - 1)).round
                    colorize(FILL_SYMBOLS[shade / TEXT_COLORS.length], "3#{TEXT_COLORS[shade % TEXT_COLORS.length]}")
                }.join
            }.each { |line| buf << line << "\n" }
            out.print(buf)
            nil
        end

        private

        # Average of the data points that fall into one output cell, or nil if none do.
        def cell_average(data, row, col, x_scale, y_scale)
            first_row = (row * y_scale).floor
            first_col = (col * x_scale).floor
            sum = 0.0
            n = 0
            (first_row..[first_row, ((row + 1) * y_scale).floor - 1].max).each { |r|
                next if r >= data.length

                (first_col..[first_col, ((col + 1) * x_scale).floor - 1].max).each { |c|
                    next if c >= data[r].length

                    sum += data[r][c]
                    n += 1
                }
            }
            n.zero? ? nil : sum / n
        end
    end

    include ColorMap
end
