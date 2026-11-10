# cmd_plot

Line plots, bar charts, histograms, color maps and tables in the terminal, for a quick
look at data from `irb`, a Rails console or a script. No dependencies; Ruby 2.7 and up.

## Installation

```ruby
# Gemfile
gem 'cmd_plot'
```

or `gem install cmd_plot`, then `require 'cmd_plot'`.

## Usage

`CmdPlot.new(width = 140, height = 40)` sets the size of the drawing area in characters.
Every method prints and returns `nil`, so the console doesn't echo anything after the plot.

```ruby
plotter = CmdPlot.new(60, 12)
```

### Line plots

Lines are drawn with braille characters, so each character cell holds 2x4 dots.

```ruby
plotter.plot((0..100).map { |i| Math.sin(i / 10.0) })
```

```
 1.00 ├       ⢀⠔⠉⠉⠑⠒⢄                               ⡔⠊⠉⠉⠒⠢⡀
      │     ⢀⡰⠁      ⠱⡀                           ⡔⠊      ⠘⢄
      │    ⢠⠃         ⠈⢢                         ⡜          ⠱⡀
      │   ⢠⠃            ⢇                       ⡜            ⠱⡀
      │  ⡠⠃             ⠈⠢⡀                   ⢠⠊              ⠱⡀
      │ ⡰⠁                ⢣                  ⢀⠇                ⠑⡄
      │                    ⢣                ⢀⠎                  ⠸⡀
      │                    ⠈⢆              ⢠⠊                    ⠱⡀
      │                      ⠱⡀           ⢠⠃                      ⠈⢆
      │                       ⠱⡀         ⡠⠃                        ⠈
      │                        ⠑⢢      ⢀⠜
-1.00 ├                          ⠑⠤⢄⣀⡠⠔⠁
      └─┴───────────────────┴──────────────────┴───────────────────┴
        0.00             33.33             66.67              100.00
```

The data can take several shapes:

| Call | Meaning |
|---|---|
| `plot([y0, y1, ...])` | y values, x is the index |
| `plot(xs, ys)` | separate x and y arrays |
| `plot({ x0 => y0, ... })` | one series as a hash |
| `plot([{ ... }, { ... }])` | several series, each in its own color |

x values can be `Date`s; the axis then shows dates. `nil` y values leave a gap. Pass
`intense: false` for the darker colors and `bold: false` for regular weight.

```ruby
start = Date.new(2026, 1, 1)
trend = (0..90).to_h { |i| [start + i, 100 + (i * 0.8)] }
wave = (0..90).to_h { |i| [start + i, 120 + (20 * Math.sin(i / 7.0))] }
plotter.plot([trend, wave])
```

```
172.00 ├                                                        ⢀⡠⠤⠒⠊
       │                                                   ⣀⡠⠔⠒⠉⠁
       │                                              ⣀⠤⠔⠒⠉
       │                                         ⣀⡠⠤⠒⠉
       │                                    ⣀⠤⠔⠒⠉
       │     ⢀⠤⠒⠒⠒⠤⡀                  ⢀⣀⠤⠒⢀⠤⠒⠒⠒⠤⡀
       │   ⢀⠔⠁     ⠈⠢⡀            ⣀⡠⠔⠒⠁ ⢀⠔⠁     ⠈⠒⡄
       │  ⡠⠊         ⠘⢄     ⢀⣀⠤⠔⠊⠉     ⢠⠃         ⠘⠤⡀               ⢠
       │ ⠜             ⠱⡀⠤⠒⠊⠁         ⡔⠁            ⠱⡀             ⡔⠁
       │           ⣀⠤⠔⠊⠉⠑⢄          ⡠⠜               ⠈⢆          ⡠⠜
       │     ⢀⣀⠤⠒⠊⠉       ⠣⡀      ⢀⠔⠁                  ⠑⡄      ⢀⠔⠁
100.00 ├ ⡠⠤⠒⠉⠁             ⠈⠢⠤⣀⣀⠤⠔⠁                     ⠈⠒⠤⣀⣀⠤⠔⠁
       └─┴───────────────────┴──────────────────┴───────────────────┴
         2026-01-01       2026-01-31      2026-03-02       2026-04-01
```

### Bar charts and histograms

```ruby
plotter.bar([12, 30, 7], %w[mon tue wed])        # optional third argument: the bar symbol
plotter.histogram(values, 8)                     # 8 equal-width bins (default 20)
plotter.histogram(values, [0, 10, 50, 100])      # or explicit bin limits
```

```
1.0:  10 °
1.5:  92 °°°°°°°°°
2.1: 292 °°°°°°°°°°°°°°°°°°°°°°°°°°°
2.7: 539 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
3.2: 542 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
3.8: 389 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
4.3: 112 °°°°°°°°°°°
4.9:  24 °°
```

### Color maps

`pcolor` draws a matrix (an array of rows) as colored blocks, averaging it down to the plot
size. Pass the number of shades as the second argument (at most 28).

```ruby
plotter.pcolor(Array.new(40) { |r| Array.new(80) { |c| Math.sin(r / 6.0) * Math.cos(c / 9.0) } })
```

### Tables

`table`, `expanded_table` and `csv` take an array of hashes, or of objects that respond to
`#attributes` such as an ActiveRecord relation. Records become hashes with string keys, so
pass field names as strings for them. All three take an optional list of fields;
`table` also takes a maximum column width.

```ruby
rows = [{ 'id' => 1, 'city' => 'Hamburg', 'adr' => 142.5 }, { 'id' => 2, 'city' => 'Lisbon', 'adr' => 118 }]
plotter.table(rows)
plotter.expanded_table(rows)
plotter.csv(rows)
plotter.table(Listing.limit(10), %w[id title], 20)
```

```
 id │    city │   adr
────┼─────────┼───────
  1 │ Hamburg │ 142.5
  2 │  Lisbon │   118

─[ RECORD 1 ]─┬────────────────────────────────────────────────────────
id            │ 1
city          │ Hamburg
adr           │ 142.5
─[ RECORD 2 ]─┬────────────────────────────────────────────────────────
id            │ 2
city          │ Lisbon
adr           │ 118

id, city, adr
1, Hamburg, 142.5
2, Lisbon, 118
```

### Output

Output goes to `$stdout` by default. To send it elsewhere, or to drop the ANSI color codes
(e.g. for a log file):

```ruby
CmdPlot.new(100, 20, out: File.open('plot.txt', 'w'), color: false).plot(values)
```

`ruby -Ilib examples/demo.rb` shows every chart type.

## Development

```sh
bundle install
bundle exec rake        # tests and RuboCop
```

## Releasing

1. Bump `CmdPlot::VERSION` in `lib/cmd_plot/version.rb` and add a section to `CHANGELOG.md`.
2. Merge to `master`, then tag and push: `git tag v0.1.0 && git push origin v0.1.0`.

The Release workflow checks that the tag matches the version, runs the tests and publishes
the gem to RubyGems.org through [trusted publishing](https://guides.rubygems.org/trusted-publishing/).
This needs a one-time setup on rubygems.org: under the gem's *Trusted publishers*, add
GitHub Actions with repository `MrBusch/cmdplot`, workflow `release.yml` and environment
`release`.

## License

GPL-2.0, see [LICENSE](LICENSE).
