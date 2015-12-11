#Grab scripture references from http://www.openbible.info/topics/KEYWORD
# usage: ruby bible_verse.rb

require 'sinatra'
require 'json'
require 'httparty'
require 'nokogiri'
require 'io/console'

set :bind, '0.0.0.0'
set :port, 3000

get "/verses/:topic" do
  topic = params[:topic]
  output_filename = case params[:format]
  when "rb", "ruby"
    "bible_reference_#{topic}.rb"
  else
    "bible_reference_#{topic}.yml"
  end
  verses = topic_verses(topic, params[:format])
  open(output_filename, 'a') do |f|
    f.puts case params[:format]
      when 'yml', 'yaml'
        "\n-#{topic}"
      when 'rb', 'ruby'
        "when \"#{topic}\"\n\t["
      else
        "\n-#{topic}"
      end
      f.puts verses
      f.puts "]\n" if (params[:format] == 'rb' || params[:format] == 'ruby')
    end
  @all_verses = verses
  @topic = topic
  erb :topic_verses
end

get "/verses/" do
  r = File.new('topics.txt')
  @all_topics = r.readlines()
  @all_verses = []
  @all_topics.each do |topic|
  verses = topic_verses(topic.gsub!(/\n/, ''))
  output_filename = case params[:format]
    when "rb", "ruby"
    'bible_references.rb'
  else
    'bible_references.yml'
  end
  verses = topic_verses(topic, params[:format])
    open(output_filename, 'a') do |f|
      f.puts case params[:format]
      when 'yml', 'yaml'
        "\n-#{topic}"
        when 'rb', 'ruby'
        "when \"#{topic}\"\n\t["
      else
        "\n-#{topic}"
      end
      f.puts verses
      f.puts "]\n" if (params[:format] == 'rb' || params[:format] == 'ruby')
    end
    @all_verses.concat(verses)
    erb :verses
  end
end

def topic_verses(topic, format='yml')
  response = HTTParty.get( "http://www.openbible.info/topics/#{topic}")
  html_doc = Nokogiri::HTML(response.body)
  verses = html_doc.css('.verse')  #selecting CSS
  captured_verses = []
  verses.each do |verse|
    reference = verse.css('.bibleref').text.strip
    case format
      when 'rb', 'ruby'
        ref = "\"#{reference}\","
      when 'yml', 'yaml'
        ref = "  #{reference}"
      else
        ref = "  #{reference}"
      end
    captured_verses.push ref unless ref.match /\d{1,2}-\d{,2}/
  end
  captured_verses
end