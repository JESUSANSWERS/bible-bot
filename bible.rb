require 'sinatra'
require 'httparty'
require 'json'

#http://getbible.net/json?" with a simple query string "p=Jn3:16" forms the base of the API

HIGHLIGHT_GOD_REFERENCES = true
CAPS_PATTERN = '*\1*'

post '/bible' do
  #return if params[:token] != ENV['SLACK_TOKEN']
  
=begin
  response 'params' include
   - token
   - team_id
   - team_domain
   - service_id
   - channel_id
   - channel_name
   - timestamp
   - user_id
   - user_name
   - text
   - trigger_word
=end
  trigger_word = params[:trigger_word].strip
  message = params[:text].gsub(trigger_word, '').strip
  
  puts "TRIGGER WORD: #{trigger_word}"
  puts "MESSAGE: #{message}"
  #switch on the trigger word
  case trigger_word
  when 'bible', 'gospel', 'scripture'
    book_name = message.match(/([a-zA-Z]+)\s+\d+:/)[1]
    book_reference = book_name[0] + book_name[-1]
    chapter_number = message.match(/(\d{1,2})\s?:\s?[\d+ | \d+\-\d+]/)[1]
    verse_number = message.match(/\d{1,2}\s?:\s?([\d+ | \d+\-\d+])/)[1]      
  else # default - ignore
  end
  
# if chapter_number includes a dash, we must retrieve several chapters in succession
# if verse_number includes a dash, we must retrieve several verses
  
  response = HTTParty.get("https://getbible.net/json?passage=#{URI.escape(message)}")  #{book_reference}#{chapter_number}:#{verse_number}")
  begin
    result = JSON.parse(response[1, response.length-3])  #the response is not pure JSON.  It is textual and requires a bit of massaging
    
    book = result["book"].first
    if book.nil? || book.empty? then exception("#{book} is null") end
=begin
  puts book
  puts book["book_name"]  #confirm the book name
  puts book["book_ref"] #match the book reference (abbreviation)
  puts book["book_nr"]  #book number
  puts book["chapter_nr"] #chapter number
=end
    
    book_name = book["book_name"]
    chapter_number = book["chapter_nr"]
    verse_number = book["chapter"].first[0]
    verse_text = book["chapter"][verse_number.to_s]["verse"]
    verse_text.gsub!(/(god)/i, CAPS_PATTERN).gsub!(/(jesus)/i, CAPS_PATTERN) if HIGHLIGHT_GOD_REFERENCES
    response_message = ":church: \nBible Verse  #{book_name} #{chapter_number}:#{verse_number}\n#{verse_text}"
  rescue 
    puts "ERROR: #{$!.message}"
    response_message = "Unable to understand #{message} :frowning:"
  end
  content_type :json
  #{:username => 'God'}
  {:response_type => "in-channel", :text => response_message }.to_json
  #{:response_type => "in-channel", :text => "Got it"}
  #{"response_type" => "in-channel", "text" => message}
end

