Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => {:registrations => "app_specific_registration/registrations", omniauth_callbacks: 'users/omniauth_callbacks'}
  mount Attachinary::Engine => "/attachinary"

  scope do
    resources :ceramiques, path: ENV['MODEL'], only: [:create, :index, :destroy, :show]
  end

  resources :orders, only: [:show, :create, :destroy] do
    resources :payments, only: [:new, :create]
  end

  resources :lessons, only: [:new, :create, :destroy, :show]

  resources :users, only: [:show, :update, :create]

  resources :articles, only: [:update, :create]

  #Stages
  get '/stage_confirmation', to: 'lessons#stage_confirmation'
  get '/stage_payment_confirmation', to: 'lessons#stage_payment_confirmation'

  #Pages
  get '/confirmation', to: 'pages#confirmation'
  get '/info', to: 'pages#info'
  get '/contact', to: 'pages#contact'
  get '/google906057532e2dbb7e', to: 'pages#google906057532e2dbb7e'
  get '/robots.txt', to: 'pages#robots', :defaults => { :format => 'txt' }

  #Sitemap
  get 'sitemap.xml', :to => 'sitemap#sitemap', :defaults => { :format => 'xml' }

  #Subscribe
  post '/user-subscribe', to: "users#subscribe"

  #Root
  root to: 'pages#home'

  #Errors
  get "/404", to: "errors#error_404"
end
