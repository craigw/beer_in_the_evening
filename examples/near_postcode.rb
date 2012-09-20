require 'beer_in_the_evening'
require 'logger'

STDOUT.sync = true
logger = Logger.new STDOUT
search = BeerInTheEvening::Search.new :logger => logger
search.postcode = 'SE1 1EY'
search.maximum_results = 5
search.minimum_rating = 6
search.wifi = true
search.each do |pub|
begin
  puts pub.to_s
rescue
  puts pub.data.to_xml
end
end
