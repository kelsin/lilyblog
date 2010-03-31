require 'rubygems'
require 'sinatra'
require 'rdiscount'
require 'haml'

# Post model
require 'post'

# Filters
before do
  cache_control :public, :max_age => 2592000

  @tags = Post.tags.sort do |a,b|
    a[0].to_s <=> b[0].to_s
  end
end

PAGE_SIZE = 2

# Helpers
helpers do
  def page
    [params[:page].to_i, 1].max
  end

  def limit
    offset = (page - 1) * PAGE_SIZE
    offset..(offset + (PAGE_SIZE - 1))
  end

  def partial(name, obj)
    Array(obj).map do |item|
      haml "_#{name}".to_sym, :locals => { name.to_sym => item }, :layout => false
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

  def add_page(url, page = 0)
    url +  (("page/#{page}/" if page >= 2) || '')
  end

  def tag_url(tag, page = 0)
    add_page "/tags/#{tag}/", page
  end

  def category_url(category, page = 0)
    add_page "/categories/#{category}/", page
  end

  def page_url(page = 0)
    add_page '/', page
  end

  def class_for_tag(tag)
    case Post.tag(tag)
    when 0.0...0.1
      'tiny'
    when 0.1...0.2
      'small'
    when 0.2...0.3
      'medium'
    when 0.3..1.0
      'large'
    end
  end
end

# Like wordpress
get %r{[^/]$} do
  redirect "#{request.path}/", 301
end

# Handle moving from wordpress
get %r{-} do
  redirect request.path.gsub(/-/,'_'), 301
end

# Categories
get '/categories/:category/page/:page/' do
  redirect "/categories/#{params[:category]}/" if params[:page].to_i < 2

  @posts = Post.find_by_category(params[:category])
  haml :posts
end

get '/categories/:category/' do
  @posts = Post.find_by_category(params[:category])
  haml :posts
end

# Tags
get '/tags/:tag/page/:page/' do
  redirect "/tags/#{params[:tag]}/" if params[:page].to_i < 2

  @tag = Post.clean_tag(params[:tag])
  @posts = Post.find_by_tag(@tag)

  pass if @posts.empty?

  haml :posts
end

get '/tags/:tag/' do
  @tag = Post.clean_tag(params[:tag])
  @posts = Post.find_by_tag(@tag)

  pass if @posts.empty?

  haml :posts
end

get '/page/:page/' do
  redirect '/' if params[:page].to_i < 2

  @posts = Post.all
  haml :posts
end

# Single Post
get '/:year/:month/:day/:slug/' do
  @post = Post.find(params)

  pass unless @post

  haml :post
end

# Get all posts
get '/' do
  @posts = Post.all
  haml :posts
end
