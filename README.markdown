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
    `-- post.erb
</pre>

All the files in the posts folder with suffix `.markdown` will be converted to HTML and cached in the cache folder.