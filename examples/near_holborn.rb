require 'beer_in_the_evening'
require 'logger'

STDOUT.sync = true
logger = Logger.new STDOUT
search = BeerInTheEvening::Search.new :logger => logger
search.tube_station = BeerInTheEvening::Location::Tube::HOLBORN
search.minimum_rating = 6
search.real_ale = true
search.wifi = true
search.food = true
random_pub = search.sort_by{rand}.first
puts random_pub.to_s
