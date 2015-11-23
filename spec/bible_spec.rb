require File.expand_path '../spec_helper.rb', __FILE__

describe "Bible Bot for Slack" do
  let(:url) { '/bible' }
  
  it "should not respond to a default route" do
    get '/'
    expect(last_response).not_to be_ok
  end
  
  it "should respond to /bible" do
    post url, {
      :user_name => "thom",
      :trigger_word => "gospel",
      :text => "gospel John 3:16"
    }
    expect(last_response).to be_ok
  end
  
  it "should provide a single verse" do
    post url, { :text => "bible John 3:16", :trigger_word => "bible"}
    response = JSON.parse(last_response.body)
    expect(response["text"]).to include("so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.")
  end
  
end