module BeerInTheEvening
  class Pub
    def initialize data
      @data = data
    end

    def name
      @data.css("td b a:first-child")[0].inner_text.to_s
    end

    def url
      "http://beerintheevening.com" + @data.css("td b a:first-child")[0]['href'].to_s
    end

    def rating
      results = @data.css("td:nth-child(3)")[0].inner_text.scan /Rating:(.*)\/10/
      results[0][0].to_f if results[0]
    end

    def visited?
      Meetup.exists? self
    end

    def distance
      results = @data.css("td:nth-child(2)")[0].inner_text.scan /Distance:(.*)miles/
      results[0][0].to_f if results[0]
    end

    def to_s
      [ name, "#{distance} miles", "#{rating} / 10", url ].join ', '
    end
  end
end
