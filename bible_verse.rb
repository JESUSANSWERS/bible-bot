#Grab scripture references from http://www.openbible.info/topics/KEYWORD
# usage: ruby bible_verse.rb

require 'sinatra'
require 'json'
require 'httparty'
require 'nokogiri'
require 'io/console'

REDIS_HEADER = "uri = URI.parse(ENV[\"REDIS_URL\"])\n uri = URI.parse('redis://h:p7d7tq2p2auh2958o5qcid1seda@ec2-54-83-33-255.compute-1.amazonaws.com:17079')\n @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)\n "

set :bind, '0.0.0.0'
set :port, 3000

get "/verses/:topic" do
  topic = params[:topic]
  output_filename = case params[:format]
  when "rb", "ruby"
    "bible_reference_#{topic}.rb"
  when "redis"
    "bible_reference_#{topic}.redis"
  else
    "bible_reference_#{topic}.yml"
  end
  verses = topic_verses(topic, params[:format])
  if params[:format] == 'redis'
  else
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
  end #if redis
  @all_verses = verses
  @topic = topic
  @filename = output_filename
  erb :topic_verse
end

get "/verses/" do
  r = File.new('topics.txt')
  all_topics = r.readlines()
  @all_verses = []
  all_topics.each do |topic|
  @output_filename = case params[:format]
    when "rb", "ruby"
      'bible_references.rb'
    when "redis"
      'bible_reference.redis'
    else
      'bible_references.yml'
    end
    verses = topic_verses(topic.gsub!(/\n/,''), params[:format])
    if params[:format] == 'redis'
      #do something completely different
      #open a different file in another 'do' loop
      #iterate all the verses and f.puts "@redis.ZADD \"#{topic}\", #{line_num}, #{verse}"
    else
      open(@output_filename, 'a') do |f|
        f.puts case params[:format]
        when 'yml', 'yaml'
          "\n-#{topic}"
          when 'rb', 'ruby'
          "when \"#{topic}\"\n\t["
        else
          "\n-#{topic}"
        end
        f.puts verses
        puts verses
        f.puts "]\n" if (params[:format] == 'rb' || params[:format] == 'ruby')
      end
      tmp_verses = {}
      tmp_verses = {topic: topic}
      tmp_verses[:verses] = verses.collect { |v| v}
      @all_verses << tmp_verses
      @all_verses
    end
  end
      erb :verses
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