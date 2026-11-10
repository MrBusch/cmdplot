# frozen_string_literal: true

class CmdPlot
    # Numeric helpers used by the plots. Kept inside the CmdPlot namespace so the gem
    # doesn't define top-level constants in the host application.
    module Data
        module_function

        # n evenly spaced floats from min to max, both ends included.
        def linspace(min, max, n)
            return [min.to_f] if n == 1

            Array.new(n) { |i| min.to_f + (i.to_f * (max.to_f - min.to_f) / (n - 1).to_f) }
        end

        # Counts values into bins.
        #
        # bins - number of equal-width bins between min and max, or an array of bin limits
        # maxcap - optional cap applied to every count
        #
        # Values below the first limit land in the first bin, values at or above the last
        # limit in the last bin.
        #
        # return - [counts, bin_centers]
        def histogram(values, bins, maxcap = nil)
            limits = bins.is_a?(Array) ? bins : linspace(values.min, values.max, bins + 1)
            counts = Array.new(limits.length - 1, 0)
            values.each { |v|
                bin = limits.index { |limit| v < limit } || counts.length
                bin = 1 if bin.zero?
                counts[bin - 1] += 1
            }
            counts = counts.map { |c| [c, maxcap].min } unless maxcap.nil?
            centers = limits.each_cons(2).map { |a, b| (a + b) / 2.0 }
            [counts, centers]
        end
    end
end
