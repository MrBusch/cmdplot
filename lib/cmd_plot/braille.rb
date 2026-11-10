# frozen_string_literal: true

class CmdPlot
    # Braille characters give each console cell a 2x4 grid of dots, which is what makes the
    # line plots smooth.
    module Braille
        BASE = 0x2800
        # Bit for each dot, indexed [row from the top][column].
        DOT_BITS = [[0x01, 0x08], [0x02, 0x10], [0x04, 0x20], [0x40, 0x80]].freeze

        module_function

        # pixels - 4 rows (top to bottom) of 2 booleans (left, right)
        def char(pixels)
            (BASE + mask(pixels)).chr(Encoding::UTF_8)
        end

        def mask(pixels)
            bits = 0
            pixels.each_with_index { |row, r|
                row.each_with_index { |set, c| bits |= DOT_BITS[r][c] if set }
            }
            bits
        end

        # Bresenham line between two points. A nil y on either end means that end has no
        # value, so only the other end is drawn.
        def line_points(x0, y0, x1, y1)
            return [] if y0.nil? && y1.nil?
            return [[x0, y0]] if y1.nil?
            return [[x1, y1]] if y0.nil?

            points = []
            dx = (x1 - x0).abs
            dy = -(y1 - y0).abs
            sx = x0 < x1 ? 1 : -1
            sy = y0 < y1 ? 1 : -1
            err = dx + dy
            loop do
                points << [x0, y0]
                break if x0 == x1 && y0 == y1

                e2 = 2 * err
                if e2 >= dy
                    err += dy
                    x0 += sx
                end
                if e2 <= dx
                    err += dx
                    y0 += sy
                end
            end
            points
        end
    end
end
