module BeerInTheEvening
  class Search
    class << self
      attr_accessor :maximum_cache_ttl
    end
    # Invalidate the cache at least every 28 days
    self.maximum_cache_ttl = 86400 * 28

    attr_accessor :tube_station
    attr_accessor :real_ale
    attr_accessor :food
    attr_accessor :wifi
    attr_accessor :minimum_rating

    attr_accessor :maximum_results

    attr_accessor :logger

    def initialize options = {}
      self.logger = options[:logger] || NullLogger.instance
    end

    def number_of_results
      matches = page(0).to_s.scan /showing \d+ to \d+ of (\d+)/
      matches[0][0].to_i
    end

    def each &block
      current_page = 0
      results_total = 0
      loop do
        logger.debug "Finding next set of results"
        results = results_on_page current_page
        break if results.empty?
        if maximum_results
          while results_total + results.size > maximum_results do
            logger.debug "Trimming results. Max = #{maximum_results}, Current = #{results_total + results.size}"
            results.pop
          end
        end
        logger.debug "Yielding #{results.size} pubs to client"
        results.each &block
        logger.debug "Client code finished"
        current_page += 1
        results_total += results.size
        break if maximum_results && results_total >= maximum_results
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
      logger.debug "Page #{n} of results will be at #{uri}"
      content = read_cache uri do
        logger.debug "Fetching #{uri}"
        open(uri).read
      end
      logger.debug "Building document from HTML data"
      doc = Nokogiri::HTML content
    end
    private :page

    def cache_generation
      Time.now.to_i / self.class.maximum_cache_ttl.to_i
    end
    private :cache_generation

    def cache_prefix
      "beer_in_the_evening-#{BeerInTheEvening::VERSION}-#{self.class.maximum_cache_ttl.to_i}-#{cache_generation}"
    end
    private :cache_prefix

    def read_cache uri
      cache_dir = Dir.tmpdir + "/#{cache_prefix}"
      Dir.mkdir cache_dir unless File.exists? cache_dir
      cache_file_name = "#{cache_dir}/#{Digest::SHA1.hexdigest(uri)}.html"
      if File.exists? cache_file_name
        logger.debug "Found #{uri} in cache at #{cache_file_name}"
        return File.read cache_file_name
      end
      logger.debug "Did not find #{uri} in cache"
      data = yield
      logger.debug "Data is #{data.bytesize}b"
      logger.debug "Adding #{uri} to cache as #{cache_file_name}"
      File.open cache_file_name, 'w+' do |f|
        f.puts data
      end
      logger.debug "Returning data"
      data
    end
    private :read_cache

    def results_on_page n
      rows = page(n).css('table.pubtable tr.pubtable').to_a
      logger.debug "Found #{rows.size} results on page #{n}"
      rows.map! { |row|
        Pub.new row
      }
      logger.debug "Returning results as pubs"
      rows
    end
    private :results_on_page
  end
end
