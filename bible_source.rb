# This should 'abstract' all the details of finding an appropriate bible verse

require 'json'
require 'httparty'

class BibleSource
#http://getbible.net/json?" with a simple query string "p=Jn3:16" forms the base of the API
  
  #perhaps, one day, these can be instance level preferences
  HIGHLIGHT_GOD_REFERENCES = true
  CAPS_PATTERN = '*\1*'
  NOISY = false
  
  def initialize(query_string)
    @ref = {}
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
  
end