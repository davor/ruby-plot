require 'rubygems' 
require 'logger'
require 'gnuplot'

unless(defined? LOGGER)
  LOGGER = Logger.new(STDOUT)
  LOGGER.datetime_format = "%Y-%m-%d %H:%M:%S "
end

require "plot_bars.rb"
require "plot_lines.rb"

#RubyPlot::test_plot_lines
#RubyPlot::test_plot_bars
