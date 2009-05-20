Fermat
======

Fermat is a dead simple, no-frills [Sinatra](http://www.sinatrarb.com/) powered blog engine. Does a blog engine need a database, editing functionality and commenting? Indeed not. Fermat parses [Markdown](http://daringfireball.net/projects/markdown/) formatted files, and that's about it. In includes rudimentary caching and RSS support, and is exceptionally simple to extend. Blogging doesn't get any simpler than this.

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

Posts
-----

There are some essentials to how posting is done in Fermat. Specifically the files must be named `yyyy-mm-dd-postname.markdown`, and the first line of the file must be the post title. An example of a Fermat supported filename is `2009-05-16-simple-fermat.markdown`.

RSS
---

Fermat includes a simple RSS feed for entries using [Builder](http://sinatra.rubyforge.org/api/classes/Sinatra/Builder.html). An example of the `rss.builder` file:

<pre>
xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Kim Joar Bekkelund"
    xml.description "Kim Joar Bekkelund's blog"
    xml.link "http://kimjoar.net/"

    @posts.each do |post|
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