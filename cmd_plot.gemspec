Gem::Specification.new do |s|
  s.name        = 'cmd_plot'
  s.version     = '0.0.1'
  s.date        = '2018-06-11'
  s.summary     = "Command line plotting for quick visualization of data."
  s.description = "This is an interface to quickly visualize data on the command line. It supports various kinds of plots (curves, bar diagram, histogram, 2D color, etc) that are presented as text output on the console."
  s.authors     = ["Andreas Buschermoehle"]
  s.email       = 'andreas@buschermoehle.org'
  s.files       = ["lib/cmd_plot.rb", "lib/cmd_plot/basic_data.rb", "lib/cmd_plot/plot.rb", "lib/cmd_plot/bar.rb", "lib/cmd_plot/pcolor.rb"]
  s.homepage    =
    'http://rubygems.org/gems/cmd_plot'
  s.license       = 'GPL-2.0'
end
