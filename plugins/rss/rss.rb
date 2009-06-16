get '/rss' do
  @posts = options.fermat.posts
  builder :rss
end