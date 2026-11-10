# frozen_string_literal: true

# Run with: ruby -Ilib examples/demo.rb
require 'cmd_plot'

plotter = CmdPlot.new(80, 20)

puts 'Line plot of y values'
plotter.plot((0..100).map { |i| Math.sin(i / 10.0) })

puts "\nTwo series over dates"
start = Date.new(2026, 1, 1)
trend = (0..90).to_h { |i| [start + i, 100 + (i * 0.8)] }
wave = (0..90).to_h { |i| [start + i, 120 + (20 * Math.sin(i / 7.0))] }
plotter.plot([trend, wave])

puts "\nHistogram"
values = Array.new(2000) { Array.new(6) { rand }.sum }
CmdPlot.new(80).histogram(values, 12)

puts "\nColor map"
CmdPlot.new(80, 20).pcolor(Array.new(40) { |r| Array.new(80) { |c| Math.sin(r / 6.0) * Math.cos(c / 9.0) } })

puts "\nTable"
rows = [{ 'id' => 1, 'city' => 'Hamburg', 'adr' => 142.5 }, { 'id' => 2, 'city' => 'Lisbon', 'adr' => 118 }]
plotter.table(rows)
puts
plotter.expanded_table(rows)
puts
plotter.csv(rows)
