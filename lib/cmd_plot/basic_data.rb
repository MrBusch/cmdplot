class BasicData

    def self.linspace(min, max, n)
        return Array.new(n) { |i| min.to_f + i.to_f * (max.to_f - min.to_f) / (n - 1).to_f }
    end

    def self.build_hist(data, bin_spec, maxcap = nil)
        min = data.min
        max = data.max
        if bin_spec.kind_of?(Array)
            limits = bin_spec
            nr_bins = limits.length - 1
        else
            limits = BasicData.linspace(min, max, bin_spec + 1)
            nr_bins = bin_spec
        end
        counts = Array.new(nr_bins, 0)
        for d in data
            bin = limits.map { |x| d < x }.index(true)
            if bin.nil?
                bin = counts.length
            end
            if bin == 0
                bin = 1
            end
            counts[bin - 1] += 1
        end
        counts = counts.map { |v| [v, maxcap].min } unless maxcap.nil?
        bin_centers = limits.each_cons(2).to_a.map { |a| (a[0] + a[1]) / 2.0 }
        return counts, bin_centers
    end

end
