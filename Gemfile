source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.7'

gem "net-http"

gem 'rails', '~> 5.2.8'
gem 'pg', '>= 1.4.5', '< 2.0'
gem 'puma', ">= 5.3.1"
gem 'sassc-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'mini_racer', platforms: :ruby

gem 'omniauth-oauth2' #, '= 1.7.0' #1.7.1 does not work
gem 'omniauth-rails_csrf_protection'
# -> https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284

gem 'active_model_serializers', '~> 0.10.0'
gem 'rest-client'
gem 'cancancan'

gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.7.0', require: false
gem 'rack-cors', require: 'rack/cors'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  gem "webdrivers"
end

gem 'bootstrap-sass', '= 3.4.1'
gem 'simple_form'
gem 'diffy'
gem "chartkick", "~> 4.0"
gem "font-awesome-rails"
gem 'cocoon'
gem 'will_paginate-bootstrap'

# Ein Wechsel zu http://leafletjs.com/ ist sinnvoll. Mindestens muss
# https://github.com/jawj/OverlappingMarkerSpiderfier eingebaut werden.
gem 'gmaps4rails'

gem 'searchkick'
gem "opensearch-ruby"

gem 'roo'
gem 'geoutm'
gem 'browser'
gem 'closure_tree'
gem 'paper_trail'
gem 'shareable_models'
gem 'friendly_id'
gem 'acts-as-taggable-on', '~> 6.0'
gem 'goldiloader'
