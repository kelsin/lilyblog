# Blog
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
