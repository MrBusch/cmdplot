# frozen_string_literal: true

class CmdPlot
    # Line plots drawn with braille dots, one color per series.
    module LinePlot
        # Accepted input:
        #   plot([y0, y1, ...])                     y values, x is the index
        #   plot([x0, x1, ...], [y0, y1, ...])      separate x and y arrays
        #   plot({ x0 => y0, x1 => y1 })            one series as a hash
        #   plot([{ x0 => y0 }, { x0 => y0 }])      several series, one color each
        #
        # x values can be Dates. nil y values leave a gap in the line.
        #
        # intense: - use the bright color variants
        # bold:    - draw the dots in bold
        def plot(data, data2 = nil, intense: true, bold: true)
            raise ArgumentError, 'a line plot needs at least 2x2 characters' if @width < 2 || @height < 2

            series = plot_series(data, data2)
            start_date = date_start(series)
            unless start_date.nil?
                series = series.map { |s| s.transform_keys { |d| (d - start_date).to_f } }
            end

            ys = series.flat_map(&:values).compact
            raise ArgumentError, 'nothing to plot: every y value is nil' if ys.empty?

            x_min, x_max = spread(*series.flat_map(&:keys).compact.minmax)
            y_min, y_max = spread(*ys.minmax)

            cells = Array.new(@height) { Array.new(@width, ' ') }
            series.each_with_index { |s, i|
                code = "#{bold ? 1 : 0};#{intense ? 9 : 3}#{TEXT_COLORS[i % TEXT_COLORS.length]}"
                draw_series(cells, dot_points(s, x_min, x_max, y_min, y_max), code)
            }

            x_ticks = Data.linspace(x_min, x_max, [2, @width / 15].max).map { |v|
                start_date.nil? ? format('%.2f', v) : (start_date + v.round).to_s
            }
            y_ticks = Data.linspace(y_max, y_min, [2, @height / 10].max).map { |v| format('%.2f', v) }

            buf = +''
            plot_area(buf, cells.map(&:join), y_ticks)
            x_axis(buf, x_ticks, y_ticks.map(&:length).max)
            out.print(buf)
            nil
        end

        private

        def plot_series(data, data2)
            return [data.zip(data2).to_h] unless data2.nil?
            return [data] if data.is_a?(Hash)
            raise ArgumentError, 'expected an array or a hash to plot' unless data.is_a?(Array)
            return [data.each_with_index.map { |y, i| [i, y] }.to_h] if data.all? { |d| d.nil? || d.is_a?(Numeric) }
            return data if data.all? { |d| d.is_a?(Hash) }

            raise ArgumentError, 'expected numbers, a hash, or an array of hashes to plot'
        end

        def date_start(series)
            keys = series.flat_map(&:keys).compact
            return nil unless keys.any? { |k| k.is_a?(Date) }
            raise ArgumentError, 'cannot mix Date and numeric x values' unless keys.all? { |k| k.is_a?(Date) }

            keys.min
        end

        # Widens a zero-width range so constant data still scales.
        def spread(min, max)
            return [min, max] unless min == max

            delta = min.zero? ? 1.0 : min.abs * 0.05
            [min - delta, max + delta]
        end

        # Scales a series onto the braille dot grid and connects consecutive points.
        def dot_points(series, x_min, x_max, y_min, y_max)
            cols = @width * 2
            rows = @height * 4
            xs = series.keys.map { |v| v.nil? ? nil : ((v - x_min) / (x_max - x_min).to_f * (cols - 1)).round }
            ys = series.values.map { |v| v.nil? ? nil : ((v - y_min) / (y_max - y_min).to_f * (rows - 1)).round }
            pairs = xs.zip(ys)
            points = if pairs.length == 1
                         pairs.reject { |_, y| y.nil? }
                     else
                         pairs.each_cons(2).flat_map { |(x0, y0), (x1, y1)| Braille.line_points(x0, y0, x1, y1) }
                     end
            points.map { |x, y| [x.clamp(0, cols - 1), y.clamp(0, rows - 1)] }
        end

        # Later series overwrite earlier ones where they share a cell.
        def draw_series(cells, points, code)
            masks = Array.new(@height) { Array.new(@width, 0) }
            points.each { |x, y|
                masks[@height - 1 - (y / 4)][x / 2] |= Braille::DOT_BITS[3 - (y % 4)][x % 2]
            }
            masks.each_with_index { |row, r|
                row.each_with_index { |mask, c|
                    next if mask.zero?

                    cells[r][c] = colorize((Braille::BASE + mask).chr(Encoding::UTF_8), code)
                }
            }
        end

        # Spreads the y ticks as evenly as the line count allows.
        def plot_area(buf, lines, y_ticks)
            tick_width = y_ticks.map(&:length).max
            spacing = (@height - y_ticks.length) / (y_ticks.length - 1)
            missing = @height - ((spacing * (y_ticks.length - 1)) + y_ticks.length)
            missing_dist = missing.zero? ? @height : y_ticks.length / missing.to_f
            next_tick = 0
            tick_offset = 0
            lines.each_with_index { |line, row|
                if next_tick < y_ticks.length && row == tick_offset + (next_tick * (spacing + 1))
                    buf << y_ticks[next_tick].rjust(tick_width) << ' ├ '
                    next_tick += 1
                    tick_offset += 1 if ((tick_offset + 1) * missing_dist) < (next_tick + 2)
                else
                    buf << (' ' * tick_width) << ' │ '
                end
                buf << line << "\n"
            }
        end

        def x_axis(buf, x_ticks, indent)
            buf << (' ' * indent) << ' └─'
            spread_between(buf, Array.new(x_ticks.length, '┴'), '─')
            buf << (' ' * indent) << '   '
            spread_between(buf, x_ticks, ' ')
        end

        # Writes the items across the plot width, padding the gaps with fill. When the
        # width doesn't divide evenly the leftover goes into the gaps one by one.
        def spread_between(buf, items, fill)
            total = items.sum(&:length)
            gap = [(@width - total) / (items.length - 1), 1].max
            missing = @width - ((gap * (items.length - 1)) + total)
            missing_dist = missing.zero? ? @width : items.length / missing.to_f
            added = 0
            items.each_with_index { |item, i|
                buf << item
                if i == items.length - 1
                    buf << "\n"
                    next
                end
                buf << (fill * gap)
                if ((added + 1) * missing_dist) < (i + 3)
                    added += 1
                    buf << fill
                end
            }
        end
    end

    include LinePlot
end
