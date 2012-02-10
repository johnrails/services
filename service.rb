require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'sinatra'

require "#{File.dirname(__FILE__)}/models/user"

# setting up our environment
env_arg = ARGV.index("-e")
env = env_arg || ENV["SINATRA_ENV"] || "development"
databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[env])
# the HTTP entry points to our service

# => get a user by name
get '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.to_json
  else
    error 404, { :error => "user not found"}.to_json
  end
end

post  '/api/v1/users' do
    begin
      user = User.create(JSON.parse(request.body.read))
      if user.valid?
        user.to_json
      else
        error 400, user.errors.to_json
      end
    rescue Exception => e
      error 400, e.message.to_json
    end
end

put '/api/v1/users' do
  user = User.find_by_name(params[:name])
  if user
    begin
      if user.update_attributes(JSON.parse(request.body.read))
        user.to_json
      else
        error 400, user.errors.to_json
      end
    rescue Exception => e
      error 400, e.message.to_json
    end
  else
    error 404, { :error  => 'user not found'}.to_json
  end
end