require 'rubygems'
require 'sinatra'
require 'maruku'

class Fermat
  attr_accessor :cache_path, :images_path, :posts_path, :posts_suffix, :cache_suffix

  def initialize
    @path           = File.dirname(__FILE__)
    @cache_path     = File.join(@path, "cache")
    @images_path    = File.join(@path, "images")
    @posts_path     = File.join(@path, "posts")
    @plugins_path   = File.join(@path, "plugins")
    @posts_suffix   = ".markdown"
    @cache_suffix   = ".html"
    @plugins_suffix = ".rb"
    @posts_cache    = "posts.marshal"

    cache if cache?
  end

  def plugins
    @plugins = Dir.glob(File.join(@plugins_path + "/**", "*" + @plugins_suffix)) if @plugins == nil

    @plugins
  end

  def post(name)
    raise "Name not valid" if name.include?("..")
    filename = File.join(@cache_path, name + @cache_suffix)
    raise "File does not exist" unless File.file?(filename) 

    File.new(filename).read
  end

  def posts
    filename = File.join(@cache_path, @posts_cache)
    raise "Posts cache does not exist" unless File.file?(filename)

    File.open(filename) do |f|
      @posts = Marshal.load(f.read())
    end

    @posts
  end

  private

  def files(type=nil)
    files = case type
      when :cache then Dir.glob(File.join(@cache_path, "*" + @cache_suffix))
      else Dir.glob(File.join(@posts_path, "*" + @posts_suffix))
    end

    files
  end

  def cache?
    Dir.mkdir("cache") unless File.directory?("cache")
    files(:post).length != files(:cache).length
  end

  def cache
    posts = []

    files.each do |filename|
      posts << Post.new(filename, self)
    end

    f = File.new(File.join(@cache_path, @posts_cache), "w")
    f.flock(File::LOCK_EX)
    f.write(Marshal.dump(posts.sort {|x,y| y.date.join("") <=> x.date.join("")}))
    f.flock(File::LOCK_UN)
    f.close
  end

  class Post
    attr_accessor :title, :body, :slug, :date

    def initialize(filename=nil, fermat=nil)
      @fermat = fermat
      from_file(filename) unless filename == nil
      cache if cache?
    end

    def from_file(filename)
      raise "File does not exist" unless File.file?(filename)

      base = File.basename(filename, @fermat.posts_suffix).split("-", 4)
      self.slug = base[3]
      self.date = base[0..2]

      File.open(filename) do |f|
        self.title = f.readline
        f.rewind
        self.body = Maruku.new(f.read).to_html
      end
    end

    def cache
      f = File.new(File.join(@fermat.cache_path, self.slug + @fermat.cache_suffix), "w")
      f.flock(File::LOCK_EX)
      f.write(self.body)
      f.flock(File::LOCK_UN)
      f.close
    end

    def cache?
      not File.file?(File.join(@fermat.cache_path, self.date.join("-") + "-" + self.slug + @fermat.posts_suffix))
    end
  end
end

configure do
  fermat = Fermat.new
  set :fermat, fermat

  @plugins = fermat.plugins
  @views = File.join(File.dirname(__FILE__), "views")
end

get '/' do
  set :views, @views
  @posts = options.fermat.posts
  erb :index
end

get '/post/:name' do
  set :views, @views
  @post = options.fermat.post(params[:name])
  erb :post
end

@plugins.each do |plugin|
  set :views, File.dirname(plugin)
  load plugin
end