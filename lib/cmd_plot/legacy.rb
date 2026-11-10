# frozen_string_literal: true

class CmdPlot
    # The 0.0.1 classes, kept so code written against them still runs. They delegate to
    # CmdPlot; new code should use CmdPlot directly.
    class Plot
        def initialize(width = 140, height = 40, _symbol = nil)
            @plotter = CmdPlot.new(width, height)
        end

        def plot(x, y = nil)
            @plotter.plot(x, y)
        end
    end

    class Bar
        def initialize(width = 140, height = 40, symbol = '°')
            @plotter = CmdPlot.new(width, height)
            @symbol = symbol
        end

        def bar(values, labels)
            @plotter.bar(values, labels, @symbol)
        end

        def histogram(values, bins = 20)
            counts, centers = Data.histogram(values, bins)
            bar(counts, centers.map { |c| c.round(1).to_s })
        end
    end

    class Pcolor
        def initialize(width = 140, height = 40)
            @plotter = CmdPlot.new(width, height)
        end

        def pcolor(data, shades = nil)
            @plotter.pcolor(data, shades)
        end
    end
end
