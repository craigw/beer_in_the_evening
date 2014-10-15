module BeerInTheEvening
  class Search
    class << self
      attr_accessor :maximum_cache_ttl
    end
    # Invalidate the cache at least every 28 days
    self.maximum_cache_ttl = 86400 * 28

    attr_accessor :postcode
    attr_accessor :tube_station
    attr_accessor :real_ale
    attr_accessor :food
    attr_accessor :wifi
    attr_accessor :minimum_rating

    attr_accessor :maximum_results

    attr_accessor :logger
    attr_accessor :sort_by

    def initialize options = {}
      self.logger = options[:logger] || NullLogger.instance
      self.sort_by = proc { |r| -r.rating }
      self.maximum_results = 100
    end

    def number_of_results
      matches = page(0).to_s.scan /showing \d+ to \d+ of (\d+)/
      matches[0][0].to_i
    end

    def each &block
      current_page = 0
      results = []
      loop do
        logger.debug "Finding next set of results"
        page_results = results_on_page current_page
        break if page_results.empty?
        if maximum_results
          while results.size + page_results.size > maximum_results do
            logger.debug "Trimming results. Max = #{maximum_results}, Current = #{results.size + page_results.size}"
            page_results.pop
          end
        end
        current_page += 1
        results += page_results
        break if maximum_results && results.size >= maximum_results
      end
      logger.debug "Yielding #{results.size} pubs to client"
      results.sort_by! &sort_by
      results.each &block
      logger.debug "Client code finished"
    end
    include Enumerable

    def escaped_postcode
      CGI.escape postcode
    end
    private :escaped_postcode

    def query_string
      params = []
      params << "tu=#{tube_station}" if tube_station
      params << "pc=#{escaped_postcode}" if postcode
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

      if minimum_rating
	# Some searches don't obey the minimum_rating parameter eg when
	# searching by postcode.
	rows.delete_if { |p| p.rating < minimum_rating }
        logger.debug "Whittled results down to #{rows.size} after strict minimum rating check"
      end
      logger.debug "Returning #{rows.size} results as pubs"
      rows
    end
    private :results_on_page
  end
end
