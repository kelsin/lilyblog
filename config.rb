# Blog
set :blog_name, 'M-x Kelsin'
set :blog_domain, 'blog.kelsin.net'
set :blog_email, 'kelsin@valefor.com'
set :blog_desc, 'Kelsin\'s blog'

# Analytics
set :property_id, 'UA-4197984-2'

# Page titles
set :posts_title, 'Posts'
set :tag_title, lambda { |tag| "Posts tagged with #{tag}" }
set :search_title, lambda { |search| "Posts containing #{search}" }

# Settings for the post class
LilyBlog::Post.page_size = 10
LilyBlog::Post.theme = 'twilight'
