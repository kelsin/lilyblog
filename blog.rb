require 'rubygems'
require 'sinatra'
require 'rdiscount'
require 'haml'
#require 'bundler'
#Bundler.setup
#Bundler.require

require 'post'

# Get all posts
get '/' do
  @posts = Post.all
  haml :posts
end
