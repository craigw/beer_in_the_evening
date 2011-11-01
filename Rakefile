require "bundler/gem_tasks"

task :generate_tube_locations do
  require 'open-uri'
  require 'nokogiri'
  options = open("http://www.beerintheevening.com/pubs/search.shtml").read
  doc = Nokogiri::HTML options
  nodes = doc.css "select[@name='tu'] option"
  station_options = nodes.to_a.select { |s| s.parent.parent.previous.xpath("./form")[0]['name'] == 'tube_select' }
  stations = station_options.to_a.map do |station|
    id = station['value'].to_i
    name = station.inner_text.to_s.strip
    next if id == 0 || name == "" # Skip blank options
    [ id, name ]
  end.compact
  tube_stations = File.dirname(__FILE__) + '/lib/beer_in_the_evening/location/tube.rb'
  File.open tube_stations, 'w+' do |f|
    f.puts "module BeerInTheEvening"
    f.puts "  module Location"
    f.puts "    module Tube"
    stations.each do |id, name|
      constant_name = name.dup
      constant_name.upcase!
      constant_name.gsub! /s+/, '_'
      constant_name.gsub! /\'/, ''
      constant_name.gsub! /[^A-Z0-9]/, '_'
      constant_name.gsub! /_+/, '_'
      constant_name.gsub! /^_+|_+$/, ''
      f.puts "      #{constant_name} = #{id}"
    end
    f.puts "    end"
    f.puts "  end"
    f.puts "end"
  end
end

task :generate_dlr_locations do
  require 'open-uri'
  require 'nokogiri'
  options = open("http://www.beerintheevening.com/pubs/search.shtml").read
  doc = Nokogiri::HTML options
  nodes = doc.css "select[@name='tu'] option"
  station_options = nodes.to_a.select { |s| s.parent.parent.previous.xpath("./form")[0]['name'] == 'dlr_select' }
  stations = station_options.to_a.map do |station|
    id = station['value'].to_i
    name = station.inner_text.to_s.strip
    next if id == 0 || name == "" # Skip blank options
    [ id, name ]
  end.compact
  tube_stations = File.dirname(__FILE__) + '/lib/beer_in_the_evening/location/dlr.rb'
  File.open tube_stations, 'w+' do |f|
    f.puts "module BeerInTheEvening"
    f.puts "  module Location"
    f.puts "    module Dlr"
    stations.each do |id, name|
      constant_name = name.dup
      constant_name.upcase!
      constant_name.gsub! /s+/, '_'
      constant_name.gsub! /\'/, ''
      constant_name.gsub! /[^A-Z0-9]/, '_'
      constant_name.gsub! /_+/, '_'
      constant_name.gsub! /^_+|_+$/, ''
      f.puts "      #{constant_name} = #{id}"
    end
    f.puts "    end"
    f.puts "  end"
    f.puts "end"
  end
end

task :generate => [ :generate_dlr_locations, :generate_tube_locations ]
