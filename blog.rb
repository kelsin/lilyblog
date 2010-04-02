require 'rubygems'
require 'sinatra'
require 'haml'

# Post model
require 'post'

# Config
set :blog_name, 'M-x Kelsin'
set :blog_url, 'http://blog.kelsin.net'
set :blog_email, 'kelsin@valefor.com'
set :blog_desc, 'Kelsin\'s blog'

set :posts_title, 'Posts'
set :tag_title, lambda { |tag| "Posts tagged with #{tag}" }
set :search_title, lambda { |search| "Posts containing #{search}" }

Post.page_size = 2
Post.theme = 'twilight'

# Filters
before do
  cache_control :public, :max_age => 2592000 unless settings.environment == :development

  @tags = Post.tags.sort do |a,b|
    a[0].to_s <=> b[0].to_s
  end
end

# Helpers
helpers do
  def title
    if @post
      @post.title
    elsif @tag
      settings.tag_title(@tag)
    elsif @search
      settings.search_title(@search)
    else
      settings.posts_title
    end
  end

  def partial(name, obj, locals = {})
    Array(obj).map do |item|
      haml "_#{name}".to_sym, :locals => { name.to_sym => item }.merge(locals), :layout => false
    end.join("\n")
  end

  def css_attrs(sheet, media = 'all')
    { :rel => 'stylesheet',
      :type => 'text/css',
      :href => "/css/#{sheet}.css",
      :media => media }
  end

  def post_url(post)
    "/#{'%02d' % post.filedate.year}/#{'%02d' % post.filedate.month}/#{'%02d' % post.filedate.day}/#{post.slug}/"
  end

  def feed_urls
    urls = [[settings.posts_title, '/feed/']]

    if word = @tag || @search
      urls.push [settings.tag_title(word), "#{tag_url(word)}feed/"]
      urls.push [settings.search_title(word), "#{search_url(word)}feed/"]
    end

    return urls
  end

  def feed_url
    if @tag
      "#{tag_url(@tag)}feed/"
    elsif @search
      "#{search_url(@search)}feed/"
    else
      '/feed/'
    end
  end

  def search_url(search)
    "/search/#{search}/"
  end

  def tag_url(tag)
    "/tags/#{tag}/"
  end

  def max_page
    (Post.count(@tag).to_f / Post.page_size.to_f).ceil
  end

  def page_url(page)
    "#{request.path}?page=#{page}"
  end

  def next_page_url
    "#{request.path}?page=#{@page + 1}"
  end

  def prev_page_url
    if @page <= 2
      request.path
    else
      "#{request.path}?page=#{@page - 1}"
    end
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

# Tags
get '/tags/:tag/' do
  @page = [params[:page].to_i, 1].max
  redirect "/tags/#{params[:tag]}/" if params[:page] and @page < 2

  @tag = Post.clean_tag(params[:tag])
  @title = "Posts tagged with #{@tag}"

  @posts = Post.find_by_tag(@tag,@page)

  haml :posts
end

# Tag Feed
get '/tags/:tag/feed/' do
  @page = 1
  @tag = Post.clean_tag(params[:tag])
  @link = "#{settings.blog_url}#{tag_url(@tag)}"

  @title = "Posts tagged with #{@tag}"

  @posts = Post.find_by_tag(@tag,@page)

  content_type 'application/rss+xml', :charset => 'utf-8'
  builder :feed
end

# Search
get '/search/:search/' do
  @search = params[:search].strip.downcase
  @posts = Post.search(@search)

  haml :posts
end

# Search Feed
get '/search/:search/feed/' do
  @search = params[:search].strip.downcase
  @link = "#{settings.blog_url}#{search_url(@search)}"

  @posts = Post.search(@search)

  content_type 'application/rss+xml', :charset => 'utf-8'
  builder :feed
end

# Posts
get '/' do
  redirect "/search/#{params[:search].strip.downcase}/" if params[:search]

  @page = [params[:page].to_i, 1].max
  redirect '/' if params[:page] and @page < 2

  @posts = Post.all(@page)

  haml :posts
end

# Feed
get '/feed/' do
  @page = 1
  @link = "#{settings.blog_url}/"

  @posts = Post.all(@page)

  content_type 'application/rss+xml', :charset => 'utf-8'
  builder :feed
end

# Single Post
get %r{^/([0-9][0-9][0-9][0-9])/([0-9][0-9])/([0-9][0-9])/([A-Za-z0-9_-]+)/$} do |year, month, day, slug|
  @post = Post.find("#{year}#{month}#{day}_#{slug}")

  haml "= partial(:post, @post, :comments => true)"
end

