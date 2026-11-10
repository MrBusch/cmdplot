# Changelog

## 0.1.0

A rewrite with a new renderer and table output.

- `CmdPlot` is now the entry point: `CmdPlot.new(width, height)` with `plot`, `bar`,
  `histogram`, `pcolor`, `table`, `expanded_table` and `csv`.
- Line plots use braille characters (2x4 dots per cell), draw lines between points, take
  several series in different colors, and support `Date` x values.
- New table output: `table`, `expanded_table` and `csv` for hashes or ActiveRecord-style
  records.
- `out:` and `color:` options to write to any IO, with or without ANSI colors.
- Constant data, single points and gaps (`nil`) plot correctly.
- Requires Ruby 2.7 or later.

Breaking:

- The top-level `BasicData` class is gone (now the internal `CmdPlot::Data`), so the gem
  no longer clashes with an application's own `BasicData`.
- `CmdPlot::Plot`, `CmdPlot::Bar` and `CmdPlot::Pcolor` still work but now draw with the
  new renderer; the `symbol` argument of `CmdPlot::Plot.new` is ignored.

## 0.0.1 - 2018-06-14

First release.
