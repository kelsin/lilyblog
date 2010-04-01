xml.instruct!
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @title
    xml.link @link
    xml.description BLOG_DESC
    xml.language "en-us"
    xml.pubDate Time.now.to_s
    xml.webMaster BLOG_EMAIL

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.link "#{BLOG_URL}#{post_url(post)}"
        xml.guid "#{BLOG_URL}#{post_url(post)}"
        xml.description post.body
        xml.pubDate post.date
      end
    end
  end
end
