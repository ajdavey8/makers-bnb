ENV["RACK_ENV"] ||= "development"
require 'sinatra/base'
require 'sinatra/flash'
require_relative 'dm_setup'

class Makersbnb < Sinatra::Base
  enable :sessions
  set :session_secret, 'cool'
  register Sinatra::Flash
  use Rack::MethodOverride

  get '/sign_up' do
    erb :sign_up
  end

  get '/search' do
    erb :'search'
  end

  get '/' do
    erb :index
  end

  post '/' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      session[:name] = user.name
      redirect '/venue'
    else
      flash[:notice] = "Incorrect email or password"
      redirect '/'
    end
  end

  get '/venue' do
    @venues = Venue.all
    @name = session[:name]
    erb :'venue/index'
  end

  get '/venue/new' do
    if session[:user_id]
      erb :'venue/new'
    else
      flash[:notice] = 'Please sign in to add venue'
      redirect '/'
    end
  end

  post '/venue' do
    user = User.get(session[:user_id])
    venue = Venue.first_or_create(
       title: params[:title], address: params[:address], city: params[:city],
        price: params[:price], description: params[:description])
    venue.pictures << Picture.first_or_create(path: params[:picture])
    venue.save
    user.venues << venue
    user.save
    redirect '/venue'
  end

  delete '/user' do
    session[:user_id] = nil
    session[:name] = nil
    flash[:notice] = 'goodbye!'
    redirect to '/'
  end

  post '/user' do
    user = User.create(name: params[:username], email: params[:email],
                      password: params[:password], password_confirmation: params[:password_confirmation])
    session[:user_id] = user.id
    session[:name] = user.name
    if user.id.nil?
      flash[:errors] = user.errors.full_messages
      redirect '/sign_up'
    end
    redirect '/venue'
  end

  get '/view/:name' do
    @name = session[:name]
    @venues = Venue.all(title: params[:name])
    session[:title] = params[:name]
    @venues.each do |venue|
      session[:last_venue] = venue.id
    end
    erb :'venue/venue_page'
  end

  post '/view/:name' do
    user = User.get(session[:user_id])
    venue = Venue.get(session[:title])
    reserve = Reservation.create(start_date: params[:startDate], end_date: params[:endDate])
    venue.reservations << reserve
    venue.save
    user.reservations << reserve
    user.save
    redirect 'view/:name'
  end

  get '/search/:city' do
    @venues = Venue.all(city: params[:city])
    erb :'venue/index'
  end

  post '/favorite/new' do
    user = User.get(session[:user_id])
    venue = Venue.get(session[:last_venue])
    favorite = Favorite.create(user_id: user.id)
    favorite.venues << venue
    favorite.save
    user.favorites << favorite
    user.save
    redirect "/view/#{venue.title}"
  end

  get '/favorite' do
    user = User.get(session[:user_id])
    favorites = Favorite.all
    all_user_with_favorites = favorites.user
      all_user_with_favorites.each do |user_with_fave|
        if user==user_with_fave
          fave = user.favorites
          @favorite_venues = fave.venues
      end
    end
    erb :'favorite/index'
  end

  get '/reservation' do
    reservation = Reservation.all
    @user_reservations = reservation.venues
    erb :'reservation/index'
  end
end
