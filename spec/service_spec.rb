require File.dirname(__FILE__) + '/../service'

require 'rspec'

require 'rack/test'

set :environment, :test

Rspec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

describe "service" do
  before(:each) do
    User.delete_all
  end
  
  describe "GET on /api/v1/users/:id" do
    before(:each) do
      User.create(
        :name => "john",
        :email => 'john@davaloseven.com',
        :password => "somedude",
        :bio  => "rails hacker")
    end
    
    it "should return a user by name" do
      get '/api/v1/users/john'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["name"].should == "john"
    end
    
    it "should return a user with an email" do
      get '/api/v1/users/john'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["email"].should == "john@davaloseven.com"
    end
    
    it "should not return a user's password" do
      get '/api/v1/users/john'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes.should_not have_key('password')
    end
    
    it "should return a user with a bio" do
      get '/api/v1/users/john' 
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["bio"].should == 'rails hacker'
    end
    
    it "should return 404 for user that doesn't exist" do
      get '/api/v1/users/foo'
      last_response.status.should == 404
    end
      
  end
end

describe "POST on /api/v1/users" do
  it "should create a user" do
    post '/api/v1/users',{
          :name       => "bob", 
          :email      => 'bob@bob.com',
          :password   => 'whatever',
          :bio         => 'java turd'
    }.to_json
    
    last_response.should be_ok
    
    get '/api/v1/users/bob'
    last_response.should be_ok
    attributes = JSON.parse(last_response.body)["user"]
    attributes['name'].should == 'bob'
    attributes['email'].should == "bob@bob.com"
    attributes['bio'].should == "java turd"
  end
end

# describe "PUT on /api/v1/users/:id" do
#   it "should update a user" do
#       put '/api/v1/users/john',{
#           :bio  => 'testing freak'
#       }.to_json
# 
#       last_response.should be_ok
# 
#       get '/api/v1/users/bryan'
# 
#       attributes = JSON.parse(last_response.body)["user"]
#       attributes["bio"].should == "testing freak"
#   end
# end