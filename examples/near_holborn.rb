require 'beer_in_the_evening'
require 'logger'

STDOUT.sync = true
logger = Logger.new STDOUT
search = BeerInTheEvening::Search.new :logger => logger
search.tube_station = BeerInTheEvening::Location::Tube::HOLBORN
search.maximum_results = 5
search.minimum_rating = 6
search.real_ale = true
search.wifi = true
search.food = true
search.each do |pub|
  puts pub.to_s
end
