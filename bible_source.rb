# This should 'abstract' all the details of finding an appropriate bible verse

require 'json'
require 'httparty'
require 'redis'

class BibleSource
#http://getbible.net/json?" with a simple query string "p=Jn3:16" forms the base of the API
  
  #perhaps, one day, these can be instance level preferences
  HIGHLIGHT_GOD_REFERENCES = true
  CAPS_PATTERN = '*\1*'
  KEY_PHRASES = /(light|truth|honest|life|live|love|serv|discipline|wise|wisdom|encourage|fear|fright|praise|worship|fellowship|money|finance|satan|devil|sin|dark|false|untru|work|testing)/i
  NOISY = false
  
  USE_REDIS = true
  
  def initialize
    @ref = {}
    if USE_REDIS
    #uri = URI.parse(ENV["REDIS_URL"])
    uri = URI.parse('redis://h:p7d7tq2p2auh2958o5qcid1seda@ec2-54-83-33-255.compute-1.amazonaws.com:17079')
        @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      @redis.ZREMRANGEBYSCORE 'testing', 1, 1000
      #test with http://zaphod-136649.nitrousapp.com:3000/bible?trigger_word=bible&text=bible%20testing
    end
  end
  
  def reference(message)
    if result = message.match(KEY_PHRASES)
      if USE_REDIS
        a_rand = rand(@redis.ZCOUNT result.to_a[1], 1, 1000)
        reference = @redis.ZRANGE "testing", a_rand, a_rand
        fetch_single_verse(reference.first)
      else
        fetch_single_verse(random_verse_for_category(result.to_a[1]).shuffle.first)
      end
    else
      fetch_single_verse(message)
    end
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
  
  def fetch_multiple_verses(verses_range)
  
  end
  
  
  def ref
    @ref
  end
  
  def random_verse_for_category(category)
    case category
      when "light"
      [
        "Psalms 119:105",
        "Matthew 4:16",
        "Matthew 5:14",
        "Matthew 5:16",
        "John 1:5",
        "John 8:12",
        "John 12:35",
        "Ephesians 5:14",
        "James 1:17",
        "1Peter 2:9",
        "1John 1:7",
        "Revelation 21:23"
        ]
      when "truth", "honest"
      [
       "Proverbs 11:3",
        "John 8:32",
        "Exodus 20:16",
        "1John 4:1",
        "1John 3:2",
        "Luke 16:10",
        "Proverbs 16:13",
        "2Kings 2:23",
        "2Kings 2:24",
        "Romans 6:23",
        "John 8:31",
        "John 8:32",
        "2Kings 23:7"
        ]
      when "life"
      [
        "John 14:6",
        "Romans 6:23",
        "Matthew 16:25",
        "John 3:16",
        "Genesis 2:7",
        "John 6:35",
        "John 10:10",
        "1Timothy 6:17",
        "1Timothy 6:18",
        "1Timothy 6:19",
        "2Peter 1:3",
        "Proverbs 13:22",
        "Ecclesiastes 7:1",
        "Romans 10:13",
        "Acts 22:16",
        "Proverbs 3:1",
        "Acts 2:38",
        "Acts 17:26",
        "Ezekiel 3:9",
        "Proverbs 12:9",
        "Proverbs 12:10",
        "Proverbs 12:11",
        "Job 5:2",
        "John 3:16",
        "John 3:17",
        "Habukkuk 2:4",
        "Leviticus 24:17",
        "Leviticus 24:18",
        "Hosea 13:16",
        "Psalms 19:1",
        "Luke 14:28",
        "Job 5:26",
        "Proverbs 12:11",
        "John 9:10",
        "Genesis 1:19"
        ]
      when "love"
      [
        "1Corinthians 16:14",
        "John 13:34-35",
        "1John 4:8",
        "Colossians 3:14",
        "John 15:13",
        "John 14:15",
        "1John 4:7",
        "1John 4:19",
        "John 3:16",
        "1Peter 4:8",
        "1John 4:18",
        "Mark 12:31",
        "1Corinthians 13:13",
        "Ephesians 5:25",
        "Luke 6:35",
        "Proverbs 10:12",
        "Ephesians 4:2",
        "Galatians 5:22",
        "Romans 12:9",
        "1John 3:18",
        "Romans 13:10",
        "Romans 12:10",
        "Matthew 22:37",
        "Galatians 2:20",
        "Leviticus 19:18",
        "Matthew 6:24",
        "John 15:9-13",
        "1John 4:21",
        "Colossians 3:14-15",
        "Ephesians 5:33",
        "Luke 6:31",
        "1Peter 3:8",
        "Romans 13:8",
        "1John 3:1",
        "Romans 5:8",
        "1John 4:16",
        "John 14:23",
        "Romans 8:38",
        "Romans 8:39",
        "Proverbs 17:9",
        "Philippians 2:2",
        "James 2:8",
        "1Timothy 1:5",
        "Psalm 116:1",
        "Galatians 5:13",
        "Zephaniah 3:17",
        "1John 4:11",
        "Galatians 5:13",
        "Galatians 5:14",
        "Matthew 10:37",
        "John 21:15-17",
        "John 14:21",
        "Philippians 1:9",
        "Proverbs 17:17",
        "1John 2:15",
        "1Peter 1:8",
        "John 13:34",
        "Proverbs 15:17",
        "Proverbs 8:17",
        "Matthew 19:19",
        "Psalm 59:16",
        "Daniel 9:4",
        "James 2:5",
        "John 17:26",
        "Song of Solomon 8:6",
        "Song of Solomon 7:6",
        "Galatians 5:22",
        "Galatians 5:23",
        "Joshua 22:5",
        "1John 3:17",
        "2Corinthians 5:14",
        "1John 4:20",
        "1John 2:5",
        "1Thessalonians 4:9",
        "1Thessalonians 3:12",
        "Ephesians 4:32",
        "Deuteronomy 7:9",
        "Romans 5:5",
        "John 13:35",
        "2Timothy 2:22",
        "Philippians 2:8",
        "Romans 6:23",
        "Mark 12:30",
        "Song of Solomon 8:6",
        "Song of Solomon 8:7",
        "Proverbs 5:19",
        "1John 3:16",
        "1Peter 1:22",
        "Hebrews 6:10",
        "Ephesians 6:24",
        "1Corinthians 13:4",
        "1Corinthians 8:1",
        "Revelation 2:4",
        "Luke 12:1"
        ]
      when "serv"
      [
        "1Peter 4:10",
        "Galatians 5:13",
        "Matthew 20:26",
        "Matthew 20:27",
        "Matthew 20:28",
        "Isaiah 58:10",
        "Mark 10:45",
        "James 2:18",
        "Ephesians 4:28",
        "2corinthians 9:12",
        "2corinthians 9:13",
        "Romans 12:6",
        "Romans 12:7",
        "Hebrews 6:10",
        "Hebrews 6:11",
        "Hebrews 6:12",
        "1Peter 4:11",
        "James 2:26",
        "1Thessalonians 5:17",
        "1Thessalonians 5:18",
        "Colossians 3:23",
        "Colossians 3:24",
        "Ephesians 4:12",
        "Romans 12:11",
        "Mark 16:16",
        "Exodus 36:2",
        "John 3:17",
        "Matthew 10:42",
        "Mark 9:35",
        "1Timothy 1:12",
        "Isaiah 55:4"
        ]
      when "discipline"
      [
        "Hebrews 12:11",
        "Proverbs 13:24",
        "1Corinthians 9:27",
        "Hebrews 12:5-6",
        "Proverbs 3:11-12",
        "Revelation 3:19",
        "Proverbs 29:15",
        "Proverbs 23:13",
        "Hebrews 12:5-11",
        "Proverbs 20:13",
        "Proverbs 6:23",
        "Titus 1:8",
        "Proverbs 29:17",
        "Hebrews 13:17",
        "Proverbs 22:15",
        "Ephesians 6:4",
        "1Timothy 4:7",
        "Proverbs 13:1",
        "Romans 7:14",
        "Psalm 94:12",
        "2Timothy 2:15",
        "Job 5:17",
        "Ephesians 6:1",
        "Psalm 119:105",
        "Proverbs 25:28",
        "2Corinthians 7:10",
        "Isaiah 1:19",
        "Deuteronomy 8:5",
        "Philippians 4:9",
        "Joshua 7:10",
        "Proverbs 28:22",
        "Hebrews 10:10",
        "2Timothy 1:7",
        "2Timothy 2:3",
        "2Timothy 2:4",
        "2Timothy 2:5",
        "Proverbs 18:9",
        "Galatians 5:22",
        "John 10:10",
        "Daniel 4:8",
        "Proverbs 12:15",
        "Proverbs 19:18",
        "Psalm 127:3",
        "Hebrews 5:8",
        "Proverbs 19:23"
      ]
      when "wise", "wisdom"
      [
        "James 1:5",
        "James 3:17",
        "Proverbs 3:13",
        "Ephesians 5:15",
        "Ephesians 5:16",
        "Ephesians 5:17",
        "Proverbs 12:15",
        "Proverbs 10:23",
        "Proverbs 18:15",
        "Proverbs 17:27",
        "Proverbs 17:28",
        "Colossians 3:16",
        "Proverbs 19:20",
        "Job 12:12",
        "Job 12:13",
        "Ecclesiastes 8:1",
        "Luke 21:15",
        "Jeremiah 9:24",
        "Proverbs 3:5",
        "Proverbs 14:16",
        "Proverbs 23:12",
        "2Timothy 2:7",
        "Proverbs 17:10",
        "Proverbs 1:7",
        "John 8:32",
        "Jeremiah 33:3",
        "Colossians 2:8",
        "Jeremiah 9:23",
        "Romans 12:2",
        "Proverbs 18:1",
        "2Timothy 1:7",
        "Proverbs 15:33",
        "John 8:12",
        "Proverbs 2:6",
        "Proverbs 16:16",
        "Proverbs 21:20",
        "Proverbs 13:20",
        "Proverbs 12:1",
        "Proverbs 3:7",
        "James 3:13",
        "Proverbs 10:8",
        "Galatians 4:9",
        "Daniel 12:3",
        "Ecclesiastes 10:12",
        "Daniel 1:17",
        "Proverbs 14:33",
        "1John 2:27",
        "Luke 12:12",
        "Proverbs 15:21",
        "Philippians 3:15",
        "Proverbs 9:10",
        "Romans 11:33",
        "Isaiah 5:21",
        "Proverbs 29:3",
        "Proverbs 15:22",
        "2Peter 3:18",
        "2Corinthians 8:7",
        "Luke 24:45",
        "Ecclesiastes 8:17",
        "Proverbs 3:35",
        "Luke 7:35",
        "Proverbs 10:21",
        "Proverbs 8:1",
        "1Timothy 6:20",
        "1Corinthians 13:11",
        "1Corinthians 3:18",
        "Proverbs 15:7",
        "2Corinthians 1:12",
        "Daniel 5:14",
        "Ephesians 5:11",
        "1Corinthians 8:2",
        "Matthew 7:24",
        "Proverbs 11:12",
        "Colossians 2:3",
        "Philippians 1:9",
        "Matthew 6:23",
        "Ecclesiastes 10:10",
        "Deuteronomy 10:18",
        "Proverbs 16:25",
        "Exodus 36:1",
        "Hosea 6:6",
        "1John 5:20",
        "Colossians 1:10",
        "Romans 12:1 "
      ]
      when "encourage"
      [
        
        ]
      when "fear", "fright"
      [
        
        ]
      when "praise", "worship"
      [
        
        ]
      when "fellowship"
      [
        
        ]
      when "money", "finance"
      [
        
        ]
      when "satan", "devil"
      [
        
        ]
      when "sin"
      [
        
        ]
      when "dark"
      [
        
        ]
      when "false", "untru"
      [
        "Genesis 3:4",
        "Leviticus 19:11",
        "Psalms 119:163",
        "Proverbs 12:22",
        "Proverbs 13:5",
        "Proverbs 14:5",
        "Proverbs 17:7",
        "Hosea 11:12",
        "Zephaniah 3:13",
        "John 8:44",
        "Acts 5:3",
        "Ephesians 4:29",
        "Colossians 3:9",
        "1Timothy 4:2",
        "James 3:1",
        "Revelation 22:15"
        ]
      when "work"
      ["Colossians 3:23",
        "Psalm 90:17",
        "Proverbs 12:11",
        "Proverbs 13:4",
        "Philippians 4:13",
        "Colossians 3:24",
        "Proverbs 12:24",
        "Proverbs 14:23",
        "Genesis 2:3",
        "Luke 1:37",
        "1Timothy 5:8",
        "Jeremiah 29:11",
        "Proverbs 6:10",
        "2Timothy 2:6",
        "Genesis 2:15",
        "Titus 2:7",
        "Proverbs 16:3"]
    end
  end
  
end