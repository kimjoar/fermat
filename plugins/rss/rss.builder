xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Kim Joar Bekkelund"
    xml.description "Kim Joar Bekkelund"
    xml.link "http://kimjoar.net/"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.link "http://kimjoar.net/post/#{post.slug}"
        xml.description post.body
        xml.pubDate Time.parse(post.date.to_s).rfc822()
        xml.guid "http://kimjoar.net/post/#{post.slug}"
      end
    end
  end
end