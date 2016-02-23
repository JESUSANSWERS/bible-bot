# This should 'abstract' all the details of finding an appropriate bible verse

require 'json'
require 'httparty'
require 'redis'
require 'nokogiri'

class BibleSource
#http://getbible.net/json?" with a simple query string "p=Jn3:16" forms the base of the API

  #perhaps, one day, these can be instance level preferences
  HIGHLIGHT_GOD_REFERENCES = true
  CAPS_PATTERN = '*\1*'
  NOISY = false

  def initialize
    @ref = {}
    uri = URI.parse(ENV["REDIS_URL"])  #ENV["REDISCLOUD_URL"]
    #test
    #uri = URI.parse('redis://h:p7d7tq2p2auh2958o5qcid1seda@ec2-107-22-209-183.compute-1.amazonaws.com:11379')
    #rackup -o 0.0.0.0 -p 3000
    #post http://zaphod-136649.nitrousapp.com:3000/bible  pass trigger_word=bible text=bible%20family
    @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  def reference(message)
    check_exists = @redis.ZRANGE "\"#{message}\"", 0, 0
    capture_list(message) if check_exists.empty?
    a_rand = rand(@redis.ZCARD "#{message}")
    reference = @redis.ZRANGE "#{message}", a_rand, a_rand
    fetch_verse(reference.first)
  end

  def fetch_verse(query_string)
    response = HTTParty.get("https://getbible.net/json?passage=#{URI.escape(query_string)}")
    begin
      result = JSON.parse(response[1, response.length-3])  #the response is not pure JSON.  It is textual and requires a bit of massaging
      book = result["book"].first
      puts "BOOK: #{book}" if NOISY
      if book.nil? || book.empty? then exception("#{book} is null") and return end

      @ref[:book_name] = book["book_name"]
      @ref[:chapter_number] = book["chapter_nr"]
      verse_number = book["chapter"].first[0]
      verse = book["chapter"][verse_number.to_s]["verse"]
      @ref[:verse_number] = verse_number
      verse.gsub!(/(god|jesus|the lord)/i, CAPS_PATTERN) if HIGHLIGHT_GOD_REFERENCES
      @ref[:verse_text] = verse
      puts @ref.inspect if NOISY
    rescue
      puts "ERROR in BibleSource: #{$!.message}"
      raise $!
    end
  end

  def ref
    @ref
  end

  def capture_list(topic)
  parsed_topic = topic.gsub(/[^a-zA-Z\d]/, '&')  #anything that is NOT alpha-numeric
  response = HTTParty.get( "http://www.openbible.info/topics/#{parsed_topic}")
  html_doc = Nokogiri::HTML(response.body)
  verses = html_doc.css('.verse')  #selecting CSS
  num = 0
    verses.each do |verse|
      reference = verse.css('.bibleref').text.strip
      num += 1
      @redis.ZADD "#{topic}", "NX", num, reference.strip unless reference.match /\d{1,2}-\d{,2}/
    end
  end

end
