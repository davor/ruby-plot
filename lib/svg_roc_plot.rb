#!/usr/bin/ruby1.8
# svg_roc_plot method - svg_roc_plot_method.rb
#       
#	Copyright 2010 vorgrimmler <dv(a_t)fdm.uni-freiburg.de>
#	This ruby method (svg_roc_plot) exports input data(from true-positive-rate and false-positive-rate arrays) to a *.svg file using gnuplot. Depending on the amount of input data is possible to create 1 to n curves in one plot. 
#	Gnuplot is needed. Please install befor using svg_roc_plot. "sudo apt-get install gnuplot" (on debian systems).
#	Usage: See below.

require 'logger'

unless(defined? LOGGER)
  LOGGER = Logger.new(STDOUT)
  LOGGER.datetime_format = "%Y-%m-%d %H:%M:%S "
end

module Svg_Roc_Plot

  def self.plot(svg_path, title, x_lable, y_lable, names, x_values, y_values, faint=nil)
    
    data = []
    (0..x_values.size-1).each do |i|
      data << y_values[i]
      data << x_values[i]
    end
    
    #Main
  	STDOUT.sync = true
  	# -----------------------------------------------------
  	# checking input
  	# -----------------------------------------------------
  	# check parameters
  	status=false
  	LOGGER.debug "#{names.length} algs entered"
  	
    #LOGGER.debug names.inspect
    #LOGGER.debug data.inspect
    
  	if names.length != data.length/2
  	    status=true
  	end
  	
  	if status
  	  raise "Usage: svg_roc_plot (svg_path(?), title(string), x-lable(string), y-lable(sting), algorithms(array), true_pos_data1(array), false_pos_data1(array), ...,  true_pos_data_n(array), false_pos_data_n(array))\n"+
  		      "       Only pairs of data are allowed but at least one.\n"+
  		      "       Each data array has to provide one float/int number from 0 to 100 per entry."
  	end
  	
  	# gnuplot check
  	gnuplot=`which gnuplot | grep -o gnuplot`
  	if gnuplot == "gnuplot\n"
  		LOGGER.debug "Gnuplot is already installed."
  	else
  		raise "Please install gnuplot.\n"+
  		      "sudo apt-get install gnuplot"
  	end
  	
  	dat_number=0
  	
  	output_dat_arr = Array.new
  	
  	
  	# -----------------------------------------------------
  	# create *.dat files of imported data for gnuplot
  	# -----------------------------------------------------
  	# write true/false arrays to one array
  	for i in 0..names.length-1#/2-1
  		true_pos_arr = data[i*2]
  		false_pos_arr = data[i*2+1]
  		#check length of input files
  		if true_pos_arr.length == false_pos_arr.length
  			#LOGGER.debug "Same length!"
  			for j in 0..true_pos_arr.length-1
  				#check if array entries are float format and between 0.0 and 100.0
  				if numeric?(true_pos_arr[j].to_s.tr(',', '.')) && true_pos_arr[j].to_s.tr(',', '.').to_f <= 100 && true_pos_arr[j].to_s.tr(',', '.').to_f >= 0
  					if  numeric?(false_pos_arr[j].to_s.tr(',', '.')) && false_pos_arr[j].to_s.tr(',', '.').to_f <= 100 && false_pos_arr[j].to_s.tr(',', '.').to_f >= 0
  						output_dat_arr[j] = "#{true_pos_arr[j]} #{false_pos_arr[j]}"
  					else
  						raise "The data of #{names[i]}  has not the right formatin at position #{j}\n"+
  						      "The right format is one float/int from 0 to 100 each line (e.g. '0'; '23,34'; '65.87' or '99')"
  					end
  				else
  					raise "The data of #{names[i]}  has not the right formatin at position #{j}+\n"
  					       "The right format is one float/int from 0 to 100 each line (e.g. '0'; '23,34'; '65.87' or '99')"
  				end
  			end
  			#-----------------------------------------------------
  			#write *.dat files
  			#-----------------------------------------------------
  			#write output_dat_arr content in new *.dat file
  			File.open( "data#{i}.dat", "w" ) do |the_file|
  			   	the_file.puts output_dat_arr
  			end
  			LOGGER.debug "data#{i}.dat created."
  			output_dat_arr.clear
  					
  		else
  			raise "Data pair of #{names[i]} have no the same number of elements."
  		end
  	end
  	
  	# -----------------------------------------------------
  	# create *.plt file for gnuplot
  	# -----------------------------------------------------
  	# 
  	output_plt_arr = Array.new
  	output_plt_arr.push "# Specifies encoding and output format"
  	output_plt_arr.push "set encoding default"
  	output_plt_arr.push "set terminal svg"
  	output_plt_arr.push "set output '#{svg_path}'"
  	output_plt_arr.push ""
  	output_plt_arr.push "# Specifies the range of the axes and appearance"
  	
  	output_plt_arr.push "set xrange [0:100]"
  	output_plt_arr.push "set yrange [0:100]"
  	output_plt_arr.push "set grid"
  	output_plt_arr.push "set title \"#{title}\""
  	output_plt_arr.push "set key invert reverse Left outside"
  	output_plt_arr.push "set xlabel \"#{x_lable}\""
  	output_plt_arr.push "set ylabel \"#{y_lable}\""
    output_plt_arr.push "set arrow from 0,0 to 100,100 nohead"
  	output_plt_arr.push ""
  	output_plt_arr.push ""
  	output_plt_arr.push ""
  	output_plt_arr.push ""
  	output_plt_arr.push "# Draws the plot and specifies its appearance ..."
  	output_plt_arr.push "plot	\\"#'random_0.dat' using 1:2 title 'random' with lines lw 1, \\"
  	i = 0
  	for i in 0..names.length-1
      
      #style = grey[i] ? "lw 1.5 lt 0" : "lw 3" 
      style = faint!=nil && faint[i] ? "lw 1.5" : "lw 4"
      
  		if i == names.length-1
  			output_plt_arr.push "	'data#{i}.dat'  using 2:1 title '#{names[i]}' with lines #{style}"
  		else
  			output_plt_arr.push "	'data#{i}.dat'  using 2:1 title '#{names[i]}' with lines #{style}, \\"
  		end
  	end
  	output_plt_arr.push ""
  	output_plt_arr.push ""
  	
  	# -----------------------------------------------------
  	# write *.plt files
  	# -----------------------------------------------------
  	# write output_dat_arr content in new *.dat file
  	File.open( "config.plt", "w" ) do |the_file|
  		the_file.puts output_plt_arr
  	end
  	LOGGER.debug "config.plt created, running gnuplot"
  	
  	# start gnuplot with created *.plt file
    cmd = "gnuplot config.plt 2>&1"
    response = ""
    IO.popen(cmd) do |f| 
      while line = f.gets
        response += line
      end
    end
    raise "gnuplot failes (cmd: "+cmd.to_s+", out: "+response.to_s+")" unless $?==0
    
  	LOGGER.debug "#{svg_path} created. "
  	
  	# -----------------------------------------------------
  	# remove *.plt and *.dat files
  	# -----------------------------------------------------
  	`rm config.plt`
  	LOGGER.debug "config.plt removed."
  	for i in 0..names.length-1
  		`rm data#{i}.dat`
  		LOGGER.debug "data#{i}.dat removed."
  	end
  end
 
  def self.test_plot
    plot("/home/martin/tmp/result.svg" , "name of title", "x-values", "y-values", ["name", "test", "bla"], [[20,60,80], [10,25,70,95], [12,78,99]], [[15,50,90],[20,40,50,70],[34,89,89]],[true,false,true])
  end
 
  private
  # float check
  def self.numeric?(object) 
   true if Float(object) rescue false
  end
end

#test function
#Svg_Roc_Plot::test_plot()
