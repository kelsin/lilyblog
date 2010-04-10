xml.instruct!
xml.rss :version => "2.0", 'xmlns:atom' => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "#{title} - #{settings.blog_name}"
    xml.link @link
    xml.description settings.blog_desc
    xml.language "en-us"
    xml.pubDate Time.now.rfc822
    xml.webMaster "#{settings.blog_email} (#{settings.name})"
    xml.tag! 'atom:link', :href => request.url, :rel => 'self', :type => 'application/rss+xml'

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.link "http://#{settings.blog_domain}#{post_url(post)}"
        xml.guid "http://#{settings.blog_domain}#{post_url(post)}"
        xml.description post.body
        xml.pubDate Time.parse(post.date.to_s).rfc822
      end
    end
  end
end
