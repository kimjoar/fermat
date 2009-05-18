require 'rubygems'
require 'sinatra'
require 'maruku'
require 'yaml'

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

  def cache
    files = Dir.glob(@posts_path + "/*" + @posts_suffix)
    cached_posts = {}
    files.each do |filename|
      file = parse_file(filename)
      f = File.new(@cache_path + "/" + file["basename"] + @cache_suffix, "w")
      f.flock(File::LOCK_EX)
      f.write(file["text"])
      f.flock(File::LOCK_UN)
      f.close

#      file.delete("text")
      cached_posts[file["date"].join("").to_i] = file
    end
    
    f = File.new(@cache_path + "/posts.marshal", "w")
    f.flock(File::LOCK_EX)
    f.write(Marshal.dump(cached_posts.sort.reverse.map {|a| a[1]}))
    f.flock(File::LOCK_UN)
    f.close
  end

  def cache?
    Dir.mkdir("cache") if !File.directory?("cache")
    Dir.glob(@posts_path + "/*" + @posts_suffix).length != Dir.glob(@cache_path + "/*" + @cache_suffix).length
  end

  def post(name)
    raise "Name not valid" if name.include?("..")
    filename = @cache_path + "/" + name + @cache_suffix
    raise "File does not exist" if !File.file?(filename) 
    
    File.new(filename).read
  end

  def posts
    filename = @cache_path + "/posts.marshal"
    raise "Posts cache does not exist" if !File.file?(filename)

    File.open(filename) do |f|
      @posts = Marshal.load(f.read())
    end

    @posts
  end
  
  def parse_file(filename)
    raise "File does not exist" if !File.file?(filename) 

    file = {}
    base = File.basename(filename, @posts_suffix).split("-", 4)
    file["basename"] = base[3]
    file["date"] = base[0..2]

    File.open(filename) do |f|
      file["heading"] = f.readline
      f.rewind
      file["text"] = Maruku.new(f.read).to_html
    end

    file
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
  
  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.rss :version => "2.0" do
      xml.channel do
        xml.title "Kim Joar Bekkelund"
        xml.description "Kim Joar Bekkelund's personal blog."
        xml.link "http://kimjoar.net/"

        @posts.each do |post|
          print post
          xml.item do
            xml.title post["heading"]
            xml.link "http://kimjoar.net/post/#{post["basename"]}"
            xml.description post["text"]
            xml.pubDate Time.parse(post["date"].to_s).rfc822()
            xml.guid "http://kimjoar.net/post/#{post["basename"]}"
          end
        end
      end
    end
  end
end