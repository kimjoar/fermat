Fermat
======

A dead simple [Sinatra](http://www.sinatrarb.com/) powered blog engine that parses [Markdown](http://daringfireball.net/projects/markdown/) formatted files.

Fermat was developed to power [Kimjoar.net](http://kimjoar.net).

Requirements
------------

* sinatra
* maruku

Default tree structure
----------------------

<pre>
.
|-- README.markdown
|-- cache
|-- fermat.rb
|-- images
|-- posts
`-- views
    |-- index.erb
    |-- layout.erb
    |-- post.erb
    `-- rss.builder
</pre>

All the files in the posts folder with suffix `.markdown` will be converted to HTML and cached in the cache folder.

RSS
---

Fermat now also includes a simple RSS feed for entries using [Builder](http://sinatra.rubyforge.org/api/classes/Sinatra/Builder.html). An example of the `rss.builder` file:

<pre>
xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Kim Joar Bekkelund"
    xml.description "Kim Joar Bekkelund's blog"
    xml.link "http://kimjoar.net/"

    @posts.each do |post|
      print post
      xml.item do
        xml.title post.heading
        xml.link "http://kimjoar.net/post/#{post.basename}"
        xml.description post.text
        xml.pubDate Time.parse(post.date.to_s).rfc822()
        xml.guid "http://kimjoar.net/post/#{post.basename}"
      end
    end
  end
end
</pre>