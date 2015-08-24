class BasicData

    # Generates an array of linearly spaced data from min to max with n entries.
    #
    # min - minimum value
    # max - maximum value
    # n - number of datapoints
    #
    # return - array with linearly spaced data
    def self.linspace(min, max, n)
        return Array.new(n) {|i| min.to_f + i.to_f*(max.to_f-min.to_f)/(n-1).to_f}
    end

    def self.build_hist(data, nr_bins, maxcap = nil)
        min = data.min
        max = data.max
        if(nr_bins.kind_of?(Array))
            limits = nr_bins
            nr_bins = limits.length-1
        else
            limits = BasicData.linspace(min, max, nr_bins+1)
        end
        # puts "Limits: " + limits.to_s
        bins = Array.new(nr_bins, 0)
        data.each do |d|
            # puts "Datapoint: " + d.to_s
            # puts "Bin position: " + limits.map {|x| d < x}.index(true).to_s
            bin = limits.map {|x| d < x}.index(true)
            if(bin.nil?) #higher than highest limit
                bin = bins.length
            end
            if(bin == 0) #lower than lowest limit
                bin = 1
            end
            bins[bin-1] += 1
        end
        if(not maxcap.nil?)
            for i in 0..(nr_bins-1)
                bins[i] = [bins[i], maxcap].min
            end
        end
        positions = limits.each_cons(2).to_a.map {|a| (a[0]+a[1])/2.0}
        return bins, positions
    end

end