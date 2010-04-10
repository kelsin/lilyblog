xml.instruct!
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{title} - #{settings.blog_name}"
    xml.link @link
    xml.description settings.blog_desc
    xml.language "en-us"
    xml.pubDate Time.now.to_s
    xml.webMaster settings.blog_email

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.link "http://#{settings.blog_domain}#{post_url(post)}"
        xml.guid "http://#{settings.blog_domain}#{post_url(post)}"
        xml.description post.body
        xml.pubDate Time.parse(post.date.to_s).to_s
      end
    end
  end
end
