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

PAGE_SIZE = 20

# Helpers
helpers do
  def page
    [@page, 1].max
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
# get %r{-} do
#   redirect request.path.gsub(/-/,'_'), 301
# end

# Tags
get %r{^/tags/([A-Za-z0-9_]+)/(page/([0-9]+)/)?$} do |tag,temp,page|
  @page = page.to_i
  @tag = Post.clean_tag(tag)

  redirect "/tags/#{tag}/" if page and @page < 2

  @posts = Post.find_by_tag(@tag)
  haml :posts
end

# Categories
get %r{^/categories/([A-Za-z0-9_]+)/(page/([0-9]+)/)?$} do |category,temp,page|
  @page = page.to_i
  @category = category.downcase

  redirect "/categories/#{category}/" if page and @page < 2

  @posts = Post.find_by_category(@category)
  haml :posts
end

# Posts
get %r{^/(page/([0-9]+)/)?$} do |temp,page|
  @page = page.to_i

  redirect '/' if page and @page < 2

  @posts = Post.all
  haml :posts
end

# Single Post
get '/:year/:month/:day/:slug/' do
  @post = Post.find(params) rescue pass

  pass unless @post

  haml :post
end

