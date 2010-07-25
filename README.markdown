Fermat
======

Fermat is a dead simple, no-frills [Sinatra](http://www.sinatrarb.com/) powered blog engine. Does a blog engine need a database, editing functionality and commenting? Indeed not. Fermat parses [Markdown](http://daringfireball.net/projects/markdown/) formatted files, and that's about it. In includes rudimentary caching and is exceptionally simple to extend because of the plugin system. Blogging doesn't get any simpler than this.

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
|-- plugins
|   `-- rss
|       |-- rss.rb
|       `-- rss.builder
|-- posts
`-- views
    |-- index.erb
    |-- layout.erb
    `-- post.erb
</pre>

Posts
-----

Posts are Markdown formatted, and must be named `yyyy-mm-dd-postname.markdown`. The first line of the file must be the post title. An example of a Fermat supported filename is `2009-05-16-simple-fermat.markdown`.

Need more functionality?
------------------------

Fermat includes a plugin system. By adding .rb files (or directories with .rb files) in the `plugins` folder, they will automatically be loaded. Check out the RSS plugin for an example. If the plugin includes views, they must be included in the same folder as the plugin.