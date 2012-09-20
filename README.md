# BeerInTheEvening

It can be hard to decide which pub to go to, right?

Wrong.


## Usage

    require 'beer_in_the_evening'
    search = BeerInTheEvening::Search.new
    search.maximum_results = 10
    search.tube_station = BeerInTheEvening::Location::Tube::HOLBORN
    search.minimum_rating = 6
    search.real_ale = true
    search.wifi = true
    search.food = true
    random_pub = search.sort_by{rand}.first
    random_pub.to_s
    # => "Lord Clyde, 2.2 miles, 6.7 / 10, http://beerintheevening.com/pubs/s/65/6501/Lord_Clyde/Canonbury"

There are a few more examples in the `examples/` directory.

## Authors

Craig R Webster <http://barkingiguana.com/>
