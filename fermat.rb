require 'rubygems'
require 'sinatra'
require 'maruku'

class Fermat
  attr_accessor :cache_path, :images_path, :posts_path, :posts_suffix, :cache_suffix

  def initialize
    @path = File.dirname(__FILE__)
    @cache_path = @path + "/cache"
    @images_path = @path + "/images"
    @posts_path = @path + "/posts"
    @posts_suffix = ".markdown"
    @cache_suffix = ".html"

    cache if cache?
  end

  def post(name)
    raise "Name not valid" if name.include?("..")
    filename = @cache_path + "/" + name + @cache_suffix
    raise "File does not exist" unless File.file?(filename) 
    
    File.new(filename).read
  end

  def posts
    filename = @cache_path + "/posts.marshal"
    raise "Posts cache does not exist" unless File.file?(filename)

    File.open(filename) do |f|
      @posts = Marshal.load(f.read())
    end

    @posts
  end

  private

  def cache?
    Dir.mkdir("cache") unless File.directory?("cache")
    Dir.glob(@posts_path + "/*" + @posts_suffix).length != Dir.glob(@cache_path + "/*" + @cache_suffix).length
  end

  def cache
    files = Dir.glob(@posts_path + "/*" + @posts_suffix)
    cached_posts = {}
    
    files.each do |filename|
      post = parse_file(filename)
      f = File.new(@cache_path + "/" + post.basename + @cache_suffix, "w")
      f.flock(File::LOCK_EX)
      f.write(post.text)
      f.flock(File::LOCK_UN)
      f.close

      cached_posts[post.date.join("").to_i] = post
    end

    f = File.new(@cache_path + "/posts.marshal", "w")
    f.flock(File::LOCK_EX)
    f.write(Marshal.dump(cached_posts.sort.reverse.map {|a| a[1]}))
    f.flock(File::LOCK_UN)
    f.close
  end

  def parse_file(filename)
    raise "File does not exist" unless File.file?(filename) 

    post = Post.new
    base = File.basename(filename, @posts_suffix).split("-", 4)
    post.basename = base[3]
    post.date = base[0..2]

    File.open(filename) do |f|
      post.heading = f.readline
      f.rewind
      post.text = Maruku.new(f.read).to_html
    end

    post
  end

  class Post
    attr_accessor :heading, :text, :basename, :date
  end
end

configure do
  fermat = Fermat.new
  set :fermat, fermat
end

get '/' do
  @posts = options.fermat.posts
  erb :index
end

get '/post/:name' do
  @post = options.fermat.post(params[:name])
  erb :post
end

get '/rss.xml' do
  @posts = options.fermat.posts
  builder :rss
end