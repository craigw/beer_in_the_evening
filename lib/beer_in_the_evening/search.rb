module BeerInTheEvening
  class Search
    attr_accessor :tube_station
    attr_accessor :real_ale
    attr_accessor :food
    attr_accessor :wifi
    attr_accessor :minimum_rating

    def number_of_results
      matches = page(0).to_s.scan /showing \d+ to \d+ of (\d+)/
      matches[0][0].to_i
    end

    def each &block
      current_page = 0
      loop do
        results = results_on_page current_page
        break if results.empty?
        results.each &block
        current_page += 1
      end
    end
    include Enumerable

    def query_string
      params = []
      params << "tu=#{tube_station}" if tube_station
      params << "ra=on" if real_ale
      params << "f=on" if food
      params << "wireless=on" if wifi
      params << "rating=#{minimum_rating}" if minimum_rating
      params.join '&'
    end
    private :query_string

    def page n
      uri = "http://www.beerintheevening.com/pubs/results.shtml?#{query_string}&page=#{n}"
      content = read_cache uri do
        open(uri).read
      end
      doc = Nokogiri::HTML content
    end
    private :page

    def read_cache uri
      cache_dir = Dir.tmpdir + "/beer_in_the_evening-#{BeerInTheEvening::VERSION}"
      Dir.mkdir cache_dir unless File.exists? cache_dir
      cache_file_name = "#{cache_dir}/#{Digest::SHA1.hexdigest(uri)}.html"
      return File.read(cache_file_name) if File.exists? cache_file_name
      data = yield
      File.open cache_file_name, 'w+' do |f|
        f.puts data
      end
      data
    end
    private :read_cache

    def results_on_page n
      page(n).css('table.pubtable tr.pubtable').to_a.map { |row|
        Pub.new row
      }
    end
    private :results_on_page
  end
end
