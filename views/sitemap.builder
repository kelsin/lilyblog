xml.instruct!
xml.urlset(:xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9',
           'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
           'xmlns:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd') do

  # Main Page
  xml.url do
    xml.loc "#{request.scheme}://#{request.host}"
    xml.changefreq 'daily'
    xml.priority '0.7'
  end

  # Other pages of main list
  2.upto max_page do |n|
    xml.url do
      xml.loc "#{request.scheme}://#{request.host}/?page=#{n}"
      xml.changefreq 'daily'
      xml.priority '0.3'
    end
  end

  # Posts
  @posts.each do |post|
    xml.url do
      xml.loc "#{request.scheme}://#{request.host}#{post_url(post)}"
      xml.changefreq 'monthly'
      xml.priority '1.0'
    end
  end
end
