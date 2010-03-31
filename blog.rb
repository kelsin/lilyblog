require 'rubygems'
require 'sinatra'
require 'rdiscount'
require 'haml'

# Post model
require 'post'

# Filters
before do
  @tags = Post.tags.sort do |a,b|
    a[0].to_s <=> b[0].to_s
  end
end

# Helpers
helpers do
  def render_posts(p)
    Array(p).map do |post|
      haml :_post, :locals => { :post => post }, :layout => false
    end.join("\n")
  end

  def stylesheet(name, media = 'all')
    Array(name).map do |sheet|
      %Q{<link rel="stylesheet" type="text/css" href="/stylesheets/#{sheet}.css" media="#{media}" />}
    end.join("\n")
  end

  def class_for_tag(tag)
    case Post.tag(tag)
    when 0.0...0.1
      'tiny'
    when 0.1...0.25
      'small'
    when 0.25...0.5
      'medium'
    when 0.5..1.0
      'large'
    end
  end
end

# Single Post
get '/posts/:id' do
  cache_control :public, :max_age => 2592000
  @post = Post.find(params[:id])
  haml :post
end

# Tags
get '/tags/:tag' do
  cache_control :public, :max_age => 2592000

  @tag = Post.clean_tag(params[:tag])
  @posts = Post.find_by_tag(@tag)
  haml :posts
end

# Get all posts
get '/' do
  cache_control :public, :max_age => 2592000
  @posts = Post.all
  haml :posts
end
