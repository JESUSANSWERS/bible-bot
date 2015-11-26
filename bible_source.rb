# This should 'abstract' all the details of finding an appropriate bible verse

require 'json'
require 'httparty'

class BibleSource
#http://getbible.net/json?" with a simple query string "p=Jn3:16" forms the base of the API
  
  #perhaps, one day, these can be instance level preferences
  HIGHLIGHT_GOD_REFERENCES = true
  CAPS_PATTERN = '*\1*'
  NOISY = false
  
  def initialize
    @ref = {}
  end
  
  def reference(message)
    case
      when message.match(/work/i)
        fetch_single_verse(random_verse_for_category(:work))
    else
      fetch_single_verse(message)
    end
  end
  
  def random_verse_for_category(category)
    case category
      when :work 
      ["Colossians 3:23", "Psalm 90:17", "Proverbs 12:11", "Proverbs 13:4", "Philippians 4:13", "Colossians 3:24", "Proverbs 12:24", "Proverbs 14:23", "Genesis 2:3", "Luke 1:37", "1Timothy 5:8", "Jeremiah 29:11", "Proverbs 6:10", "2Timothy 2:6", "Genesis 2:15", "Titus 2:7", "Proverbs 16:3"].shuffle.first
    end
  end
  
  def fetch_multiple_verses(verses_range)
  end
  
  def fetch_single_verse(query_string)
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