require 'rubygems'
require 'sinatra'
require 'maruku'

class Fermat
  attr_accessor :cache_path, :images_path, :posts_path, :posts_suffix, :cache_suffix

  def initialize
    @path         = File.dirname(__FILE__)
    @cache_path   = File.join(@path, "cache")
    @images_path  = File.join(@path, "images")
    @posts_path   = File.join(@path, "posts")
    @posts_suffix = ".markdown"
    @cache_suffix = ".html"

    cache if cache?
  end

  def post(name)
    raise "Name not valid" if name.include?("..")
    filename = File.join(@cache_path, name + @cache_suffix)
    raise "File does not exist" unless File.file?(filename) 
    
    File.new(filename).read
  end

  def posts
    filename = File.join(@cache_path, "posts.marshal")
    raise "Posts cache does not exist" unless File.file?(filename)

    File.open(filename) do |f|
      @posts = Marshal.load(f.read())
    end

    @posts
  end

  private

  def cache?
    Dir.mkdir("cache") unless File.directory?("cache")
    Dir.glob(File.join(@posts_path, "*" + @posts_suffix)).length != Dir.glob(File.join(@cache_path, "*" + @cache_suffix)).length
  end

  def cache
    files = Dir.glob(File.join(@posts_path, "*" + @posts_suffix))
    cached_posts = {}
    
    files.each do |filename|
      post = parse_file(filename)
      f = File.new(File.join(@cache_path, post.slug + @cache_suffix), "w")
      f.flock(File::LOCK_EX)
      f.write(post.body)
      f.flock(File::LOCK_UN)
      f.close

      cached_posts[post.date.join("").to_i] = post
    end

    f = File.new(File.join(@cache_path, "posts.marshal"), "w")
    f.flock(File::LOCK_EX)
    f.write(Marshal.dump(cached_posts.sort.reverse.map {|a| a[1]}))
    f.flock(File::LOCK_UN)
    f.close
  end

  def parse_file(filename)
    raise "File does not exist" unless File.file?(filename) 

    post = Post.new
    base = File.basename(filename, @posts_suffix).split("-", 4)
    post.slug = base[3]
    post.date = base[0..2]

    File.open(filename) do |f|
      post.title = f.readline
      f.rewind
      post.body = Maruku.new(f.read).to_html
    end

    post
  end

  class Post
    attr_accessor :title, :body, :slug, :date
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