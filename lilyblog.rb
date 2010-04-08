# LilyBlog
# A Sinatra based blog engine
#
# Author:: Christopher Giroir (kelsin@valefor.com)
#
# This is the main file containing the LilyBlog sinatra blogging engine.

require 'rubygems'
require 'sinatra'
require 'erb'
require 'haml'

# Add lib directory to load path
LILYBLOG_ROOT = File.dirname(__FILE__)
$:.unshift "#{LILYBLOG_ROOT}/lib"

# LilyBlog files
require 'lilyblog/post'
require 'lilyblog/helpers'

# Config
set :blog_name, 'Blog Name'
set :blog_domain, 'url.to.blog.com'
set :blog_email, 'admin@blog.com'
set :blog_desc, 'Description of Blog'

# Analytics
set :property_id, nil

# Page titles
set :posts_title, 'Posts'
set :tag_title, lambda { |tag| "Posts tagged with #{tag}" }
set :search_title, lambda { |search| "Posts containing #{search}" }

# Settings for the post class
LilyBlog::Post.page_size = 10
LilyBlog::Post.theme = 'twilight'

# Filters
before do
  # Cache settings, cache everything for a month!
  cache_control :public, :must_revalidate, :max_age => 2592000 unless settings.environment == :development

  if settings.environment == :production and request.host != settings.blog_domain
    redirect "http://#{settings.blog_domain}#{request.path}"
  end

  @page = 1

  # Load tags and sort them for views
  @tags = LilyBlog::Post.tags.sort do |a,b|
    a[0].to_s <=> b[0].to_s
  end
end

# Helpers
helpers do
  include LilyBlog::Helpers
end

# Robots file (dynamic for url)
get '/robots.txt' do
  content_type 'text/plain', :charset => 'utf-8'
  erb :robots
end

# Match all routes that don't end in / and return a 301 redirect to add a /
get %r{[^/]$} do
  redirect "#{request.path}/", 301
end

# Tags
get '/tags/:tag/' do
  @page = [params[:page].to_i, 1].max
  redirect "/tags/#{params[:tag]}/" if params[:page] and @page < 2

  @tag = LilyBlog::Post.clean_tag(params[:tag])
  @title = "Posts tagged with #{@tag}"

  @posts = LilyBlog::Post.find_by_tag(@tag,@page)

  haml :posts
end

# Tag Feed
get '/tags/:tag/feed/' do
  @tag = LilyBlog::Post.clean_tag(params[:tag])
  @link = "http://#{settings.blog_domain}#{tag_url(@tag)}"

  @title = "Posts tagged with #{@tag}"

  @posts = LilyBlog::Post.find_by_tag(@tag,@page)

  content_type 'application/rss+xml', :charset => 'utf-8'
  builder :feed
end

# Search
get '/search/:search/' do
  @search = params[:search].strip.downcase
  @posts = LilyBlog::Post.search(@search)

  haml :posts
end

# Search Feed
get '/search/:search/feed/' do
  @search = params[:search].strip.downcase
  @link = "http://#{settings.blog_domain}#{search_url(@search)}"

  @posts = LilyBlog::Post.search(@search)

  content_type 'application/rss+xml', :charset => 'utf-8'
  builder :feed
end

# Posts
get '/' do
  redirect "/search/#{params[:search].strip.downcase}/" if params[:search]

  @page = [params[:page].to_i, 1].max
  redirect '/' if params[:page] and @page < 2

  @posts = LilyBlog::Post.get(@page)

  haml :posts
end

# Feed
get '/feed/' do
  @link = "http://#{settings.blog_domain}/"

  @posts = LilyBlog::Post.get(@page)

  content_type 'application/rss+xml', :charset => 'utf-8'
  builder :feed
end

# Single Post
get %r{^/([0-9][0-9][0-9][0-9])/([0-9][0-9])/([0-9][0-9])/([A-Za-z0-9_-]+)/$} do |year, month, day, slug|
  @post = LilyBlog::Post.find("#{year}#{month}#{day}_#{slug}")

  haml :post
end

# Sitemap
get '/sitemap.xml/' do
  @posts = LilyBlog::Post.all

  content_type 'application/xml', :charset => 'utf-8'
  builder :sitemap
end

__END__

# Post partial (since this is online one line we're including it here instead of
# adding a file
@@ post
= partial :post, @post, :comments => true
