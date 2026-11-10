# frozen_string_literal: true

require_relative 'lib/cmd_plot/version'

Gem::Specification.new do |s|
    s.name = 'cmd_plot'
    s.version = CmdPlot::VERSION
    s.summary = 'Line plots, bar charts, histograms, color maps and tables in the terminal.'
    s.description = 'Quick visualization of data on the command line: braille line plots with ' \
                    'several series and date axes, bar charts, histograms, 2D color maps, and ' \
                    'table/CSV dumps of hashes or ActiveRecord-style records. No dependencies.'
    s.authors = ['Andreas Buschermoehle']
    s.email = 'andreas@buschermoehle.org'
    s.homepage = 'https://github.com/MrBusch/cmdplot'
    s.license = 'GPL-2.0'
    s.required_ruby_version = '>= 2.7'

    s.files = Dir['lib/**/*.rb'] + %w[README.md CHANGELOG.md LICENSE]
    s.require_paths = ['lib']

    s.metadata = {
        'homepage_uri' => s.homepage,
        'source_code_uri' => s.homepage,
        'changelog_uri' => "#{s.homepage}/blob/master/CHANGELOG.md",
        'bug_tracker_uri' => "#{s.homepage}/issues",
        'rubygems_mfa_required' => 'true'
    }
end
