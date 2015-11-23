require File.expand_path '../spec_helper.rb', __FILE__

describe "Bible Bot for Slack" do
  it "should not respond to a default route" do
    get '/'
    expect(last_response).not_to be_ok
  end
  
  it "should respond to /bible" do
    post '/bible'
    expect(last_response).to be_ok
  end
  
  it "should respond with JSON" do
    pending("Verify JSON is returned")
    fail
  end
end