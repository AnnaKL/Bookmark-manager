require 'sinatra/base'
require 'data_mapper'
require './lib/link.rb'
require './lib/tag.rb'
require './lib/user.rb'
require 'rack-flash'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmarkmanager_#{env}")

DataMapper.finalize

DataMapper.auto_upgrade!


class BookmarkManager < Sinatra::Base
  set :views, proc { File.join(root,'views') }
  enable :sessions
  set :session_secret, 'super secret'
  use Rack::Flash, :sweep => true


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

  get '/user/new' do
    @user = User.new
    erb :'user/new'
  end

  post '/user' do
    @user = User.create(email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])
    if @user.save
    session[:user_id] = @user.id
    redirect to('/')
    else
    flash[:notice] = 'Sorry, your passwords do not match'
    erb :'user/new'
  end
  end

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
