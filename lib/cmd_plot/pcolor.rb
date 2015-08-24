class CmdPlot::Pcolor

  #red, green, brown, blue, magenta, cyan, gray
  TEXT_COLORS = [31, 32, 33, 34, 35, 36, 37]
  FILL_SYMBOLS = ['█', '░', '▒', '▓']
  
  def initialize(width = 140, height = 40, symbol = '°')
    @width = width    #width of the plot in characters
    @height = height  #height of the plot in lines
    @symbol = symbol[0] #plotting symbol
  end

  def pcolor(data, shades = nil)
    shades = data.flatten.uniq.length if(shades.nil?)
    shades = TEXT_COLORS.length*FILL_SYMBOLS.length if(shades > TEXT_COLORS.length*FILL_SYMBOLS.length or shades <= 0)
    x_scale = data[0].length/@width.to_f
    y_scale = data.length/@height.to_f
    z_max = data.map{|r| r.max}.max
    z_min = data.map{|r| r.min}.min
    puts "Pcolor with x_scale: #{x_scale}, y_scale: #{y_scale}, z_min: #{z_min}, z_max: #{z_max}"

    scaled_data = Array.new(@height) { Array.new(@width){0.0} }
    for row in 0..(scaled_data.length-1)
      for col in 0..(scaled_data[row].length-1)
        n = 0.0
        for d_row in (row*y_scale).floor..[(row*y_scale).floor, ((row+1)*y_scale).floor-1].max
          for d_col in (col*x_scale).floor..[(col*x_scale).floor, ((col+1)*x_scale).floor-1].max
            if(d_row >= 0 and d_row < data.length and d_col >= 0 and d_col < data[d_row].length)
              scaled_data[row][col] += data[d_row][d_col]
              n += 1.0
            end
          end
        end
        if(n > 0)
          scaled_data[row][col] /= n
        else
          scaled_data[row][col] = nil
        end
      end
    end

    #full picture starts out empty
    pic = Array.new(@height) { Array.new(@width){nil} }
    #run through data and fill in the plotting symbol/color
    for row in 0..(scaled_data.length-1)
      for col in 0..(scaled_data[row].length-1)
        val = scaled_data[row][col]
        unless(val.nil?)
          fill = ((val-z_min)/(z_max-z_min).to_f * (shades-1)).round
          pic[row][col] = fill
        end
      end
    end

    for row in pic
      for col in row
        unless(col.nil?)
          color = TEXT_COLORS[col % TEXT_COLORS.length]
          sym = FILL_SYMBOLS[col/TEXT_COLORS.length]
          print "\e[#{color}m#{sym}\e[0m"
        else
          print ' '
        end
      end
      print "\n"
    end
    return nil
  end
end