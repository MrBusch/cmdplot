class CmdPlot::Bar
  def initialize(width = 140, height = 40, symbol = '°')
    @width = width    #width of the plot in characters
    @height = height  #height of the plot in lines
    @symbol = symbol[0] #plotting symbol
  end
  
  def bar(height, labels)
    max_height = height.max.to_f
    max_label = labels.map{|l| l.length}.max
    max_num = height.map{|l| l.to_s.length}.max
    for data in height.zip(labels)
        puts "#{' '*(max_label-data[1].length)}#{data[1]}: #{' '*(max_num-data[0].to_s.length)}#{data[0]} #{@symbol*((data[0]/max_height)*(@width-max_label-max_num-3)).round}"
    end
    return nil
  end

  def histogram(data, bins = 20)
    bins, positions = BasicData.build_hist(data, bins)
    bar(bins, positions.map{|p| p.round(1).to_s})
  end
end