require 'rubygems'
require 'sinatra'
require 'rdiscount'
require 'haml'

# Post model
require 'post'

# Config
PAGE_SIZE = 10
BLOG_NAME = "M-x Kelsin"
BLOG_URL = "http://blog.kelsin.net"
BLOG_EMAIL = "kelsin@valefor.com"
BLOG_DESC = "BLOG"

# Filters
before do
  cache_control :public, :max_age => 2592000 unless settings.environment == :development
  content_type 'text/html', :charset => 'ISO-8859-1'

  @tags = Post.tags.sort do |a,b|
    a[0].to_s <=> b[0].to_s
  end
end

# Helpers
helpers do
  def title
    @title ? "#{@title} - #{BLOG_NAME}" : BLOG_NAME
  end

  def partial(name, obj, locals = {})
    Array(obj).map do |item|
      haml "_#{name}".to_sym, :locals => { name.to_sym => item }.merge(locals), :layout => false
    end.join("\n")
  end

  def stylesheet(name, media = 'all')
    Array(name).map do |sheet|
      %Q{<link rel="stylesheet" type="text/css" href="/stylesheets/#{sheet}.css" media="#{media}" />}
    end.join("\n")
  end

  def post_url(post)
    "/#{'%02d' % post.date.year}/#{'%02d' % post.date.month}/#{'%02d' % post.date.day}/#{post.slug}/"
  end

  def add_page(url, page)
    url +  (("page/#{page}/" if page >= 2) || '')
  end

  def tag_url(tag, page = 1)
    add_page "/tags/#{tag}/", page
  end

  def page_url(page = 1)
    add_page '/', page
  end

  def class_for_tag(tag)
    case Post.tag(tag)
    when 0.0...0.02
      'tiny'
    when 0.02...0.04
      'small'
    when 0.04...0.06
      'medium'
    when 0.06...0.08
      'large'
    when 0.08..1.0
      'enormous'
    end
  end
end

# Like wordpress
get %r{[^/]$} do
  redirect "#{request.path}/", 301
end

# Handle moving from wordpress
# get %r{-} do
#   redirect request.path.gsub(/-/,'_'), 301
# end

# Tags
get %r{^/tags/([A-Za-z0-9_-]+)/(page/([0-9]+)/)?$} do |tag,temp,page|
  @page = [page.to_i, 1].max
  @tag = Post.clean_tag(tag)
  @title = "Posts tagged by #{@tag}"

  redirect "/tags/#{tag}/" if page and @page < 2

  @posts = Post.find_by_tag(@tag,@page) rescue pass
  haml :tags
end

# Posts
get %r{^/(page/([0-9]+)/)?$} do |temp,page|
  @page = [page.to_i, 1].max

  redirect '/' if page and @page < 2

  @posts = Post.all(@page) rescue pass
  haml :posts
end

# Feed
get '/feed/' do
  content_type 'application/rss+xml', :charset => 'ISO-8859-1'
  @page = 1
  @posts = Post.all(@page) rescue pass
  builder :feed
end

# Single Post
get %r{^/([0-9][0-9][0-9][0-9])/([0-9][0-9])/([0-9][0-9])/([A-Za-z0-9_-]+)/$} do |year, month, day, slug|
  @post = Post.find("#{year}#{month}#{day}_#{slug}") rescue pass
  @title = @post.title

  haml :post
end

