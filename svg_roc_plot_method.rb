#!/usr/bin/ruby1.8
# svg_roc_plot method - svg_roc_plot_method.rb
#       
#	Copyright 2010 vorgrimmler <dv(a_t)fdm.uni-freiburg.de>
#	This ruby method (svg_roc_plot) exports inputs data(from true-positive-rate and false-positive-rate arrays) to a *.svg file using gnuplot. Depending on the amount of input data is possible to create 1 to n curves in one plot. 
#	Gnuplot is needed. Please install befor using svg_roc_plot. "sudo apt-get install gnuplot" (on debian systems).
#	Usage: See below.

def svg_roc_plot(svg_path, title, x_lable, y_lable, names, *data)
	# Main
	STDOUT.sync = true
	# -----------------------------------------------------
	# checking input
	# -----------------------------------------------------
	# check parameters
	status=false
	puts "#{names.length} algs entered"
	
	if names.length != data.length/2
	    status=true
	end
	
	if status
	    puts "Usage: svg_roc_plot (svg_path(?), title(string), x-lable(string), y-lable(sting), algorithms(array), true_pos_data1(array), false_pos_data1(array), ...,  true_pos_data_n(array), false_pos_data_n(array))"
		puts "       Only pairs of data are allowed but at least one."
		puts "       Each data array has to provide one float/int number from 0 to 100 per entry."
	    exit
	end
	
	# gnuplot check
	gnuplot=`which gnuplot | grep -o gnuplot`
	if gnuplot == "gnuplot\n"
		puts "Gnuplot installed."
	else
		puts "Please install gnuplot."
		puts "sudo apt-get install gnuplot"
		exit
	end
	
	dat_number=0
	# -----------------------------------------------------
	# create random_0.dat file for gnuplot
	# -----------------------------------------------------
	output_dat_arr = Array.new
	for i in 0..100
		output_dat_arr[i] = "#{i} #{i}"
	end
	# -----------------------------------------------------
	# write random_0.dat files
	# -----------------------------------------------------
	# write output_dat_arr content in new *.dat file
	File.open( "random_#{dat_number}.dat", "w" ) do |the_file|
	   	the_file.puts output_dat_arr
	end
	puts "random_#{dat_number}.dat created."
	output_dat_arr.clear
	
	# float check
	def numeric?(object)
	  true if Float(object) rescue false
	end
	
	# -----------------------------------------------------
	# create *.dat files of imported data for gnuplot
	# -----------------------------------------------------
	# write true/false arrays to one array
	for i in 0..names.length-1#/2-1
		true_pos_arr = data[i*2]
		false_pos_arr = data[i*2+1]
		#check length of input files
		if true_pos_arr.length == false_pos_arr.length
			#puts "Same length!"
			for j in 0..true_pos_arr.length-1
				#check if array entries are float format and between 0.0 and 100.0
				if numeric?(true_pos_arr[j].to_s.tr(',', '.')) && true_pos_arr[j].to_s.tr(',', '.').to_f <= 100 && true_pos_arr[j].to_s.tr(',', '.').to_f >= 0
					if  numeric?(false_pos_arr[j].to_s.tr(',', '.')) && false_pos_arr[j].to_s.tr(',', '.').to_f <= 100 && false_pos_arr[j].to_s.tr(',', '.').to_f >= 0
						output_dat_arr[j] = "#{true_pos_arr[j]} #{false_pos_arr[j]}"
					else
						puts "The data of #{names[i]}  has not the right formatin at position #{j}"
						puts "The right format is one float/int from 0 to 100 each line (e.g. '0'; '23,34'; '65.87' or '99')"
						exit
					end
				else
					puts "The data of #{names[i]}  has not the right formatin at position #{j}"
					puts "The right format is one float/int from 0 to 100 each line (e.g. '0'; '23,34'; '65.87' or '99')"
					exit
				end
			end
			
			#-----------------------------------------------------
			#write *.dat files
			#-----------------------------------------------------
			#write output_dat_arr content in new *.dat file
			File.open( "#{names[i-2]}.dat", "w" ) do |the_file|
			   	the_file.puts output_dat_arr
			end
			puts "#{names[i-2]}.dat created."
			output_dat_arr.clear
					
		else
			puts "Data pair of #{names[i]} have no the same number of elements."
			exit
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
	output_plt_arr.push "set key outside right"
	output_plt_arr.push "set xlabel \"#{x_lable}\""
	output_plt_arr.push "set ylabel \"#{y_lable}\""
	output_plt_arr.push ""
	output_plt_arr.push ""
	output_plt_arr.push ""
	output_plt_arr.push ""
	output_plt_arr.push "# Draws the plot and specifies its appearance ..."
	output_plt_arr.push "plot	'random_0.dat' using 1:2 title 'random' with lines, \\"
	i = 0
	for i in 0..names.length-1
		if i == names.length-1
			output_plt_arr.push "	'#{names[i]}.dat'  using 2:1 title '#{names[i]}' with lines"
		else
			output_plt_arr.push "	'#{names[i]}.dat'  using 2:1 title '#{names[i]}' with lines, \\"
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
	puts "config.plt created."
	
	# start gnuplot with created *.plt file
	`gnuplot config.plt`
	puts "#{svg_path} created."
	
	# -----------------------------------------------------
	# remove *.plt and *.dat files
	# -----------------------------------------------------
	`rm config.plt`
	puts "config.plt removed."
	`rm random_0.dat`
	puts "random_0.dat removed."
	for i in 0..names.length-1
		`rm #{names[i]}.dat`
		puts "#{names[i]}.dat removed."
	end
end

#test function
#svg_roc_plot("/media/sda4/baloerrach/work/guetlein/svg_roc_plot/result.svg" , "name of title", "pos", "neg", ["name1", "name2"], [20,60,80], [15,50,90],[10,25,70,95],[20,40,50,70])
