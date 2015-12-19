require 'sinatra'
require 'json'
require './bible_source'

TRIGGER_WORDS = ['bible', 'gospel', 'scripture']

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
  
  bible = BibleSource.new
  if TRIGGER_WORDS.include?(trigger_word)
    bible.fetch_verse(message)
  else #trigger_word is 'advice'?
    bible.reference(message)
  end
  
  response_message = "Unable to understand #{message} :frowning:"  #default response
  begin
    response_message = ":church: \nBible Verse  #{bible.ref[:book_name]} #{bible.ref[:chapter_number]}:#{bible.ref[:verse_number]}\n#{bible.ref[:verse_text]}"
  rescue 
    puts "ERROR: #{$!.message}"
  end
  content_type :json
  {:username => 'god', :response_type => "in-channel", :text => response_message }.to_json
end

