require 'sinatra/base'
require 'data_mapper'
require './lib/link.rb'
require './lib/tag.rb'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmarkmanager_#{env}")

DataMapper.finalize

DataMapper.auto_upgrade!


class BookmarkManager < Sinatra::Base


  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params['url']
    title = params['title']
    tags = params['tags'].split(' ').map do |tag|
    Tag.first_or_create(text: tag)
  end
  Link.create(url: url, title: title, tag: tags)
  redirect to('/')
  end

  get '/tag/:text' do
    tag = Tag.first(text: params[:text])
    @links = tag ? tag.links : []
    erb :index
  end
  # start the server if ruby file executed directly
  run! if app_file == $0
end
