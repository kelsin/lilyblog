require 'rubygems'
require 'sinatra'
require 'rdiscount'
require 'haml'

# Post model
require 'post'

# Helpers
helpers do
  def stylesheet(name, media = 'all')
    Array(name).map do |sheet|
      %Q{<link rel="stylesheet" type="text/css" href="/stylesheets/#{sheet}.css" media="#{media}" />}
    end.join("\n")
  end
end

# Get all posts
get '/' do
  @posts = Post.all
  haml :posts
end
