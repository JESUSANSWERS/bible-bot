require 'rack/test'
require 'rspec'

require File.expand_path '../../bible.rb', __FILE__

ENV['RACK_ENV'] = 'test'
ENV['REDIS_URL'] = "redis://h:p7d7tq2p2auh2958o5qcid1seda@ec2-54-83-33-255.compute-1.amazonaws.com:17079"

module RSpecMixin
  include Rack::Test::Methods
  #def app() Bible end
  def app() Sinatra::Application end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }
