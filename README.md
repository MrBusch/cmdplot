# cmdplot
A command line plotting library for ruby

## Examples

### Line plot

```x = (1..100).map { |v| v / 100.0 * 6.3 }
y = x.map { |v| Math.sin(v) }
CmdPlot::Plot.new.plot(x, y)
```
![Line plot](https://raw.githubusercontent.com/MrBusch/cmdplot/master/examples/lineplot.png "Line plot")
