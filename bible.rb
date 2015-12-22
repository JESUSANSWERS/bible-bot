require 'sinatra'
require 'json'
require './bible_source'

KEYWORDS = ['verse', 'gospel', 'scripture']
FILLER_WORDS = ['in', 'of', 'about', 'when', 'with', 'about', 'for', 'to']

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
  #trigger_word should always be 'bible'
  if (KEYWORDS.collect { |kw| message.split.include?(kw) }).include? true
    bible.fetch_verse(/\d{1}?\s*[a-zA-Z]*\s*\d{1,2}:\d{1,3}/.match(message)[0])
  else
    bible.reference (message.downcase.split - FILLER_WORDS).join(' ')
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

