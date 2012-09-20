module BeerInTheEvening
  class Pub
    attr_accessor :data
    private :data=

    def initialize data
      self.data = data
    end

    def distance_known?
      !distance.nil?
    end

    def name
      data.css("td b a:first-child")[0].inner_text.to_s.strip
    end

    def url
      "http://beerintheevening.com" + self.data.css("td b a:first-child")[0]['href'].to_s
    end

    def rating_column
      distance_known? ? 3 : 2
    end

    def rating
      results = data.css("td:nth-child(#{rating_column})")[0].inner_text.scan /Rating:(.*)\/10/
      results[0][0].to_f if results[0]
    end

    def distance
      results = data.css("td:nth-child(2)")[0].inner_text.scan /Distance:(.*)miles/
      results[0][0].to_f if results[0]
    rescue
    end

    def to_s
      if distance_known?
        [ name, "#{distance} miles", "#{rating} / 10", url ]
      else
        [ name, "#{rating} / 10", url ]
      end.join ', '
    end
  end
end
