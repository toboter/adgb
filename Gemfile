source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.2'

gem "net-http"
gem "csv"
gem "ostruct"

gem 'rails', '~> 8.1.0', '>= 8.1.4.1'
# concurrent-ruby pin no longer required on Rails 8 / Ruby 3.2+
gem 'pg', '>= 1.4.5', '< 2.0'
gem 'puma', '>= 7.2.1'
gem 'sassc-rails'
gem 'uglifier', '>= 1.3.0'
# ExecJS 2.8.x passes create_additions to JSON.parse; incompatible with json 3.x
gem 'execjs', '>= 2.10'
# Keep Sprockets (do not introduce Webpacker / Propshaft this upgrade).
gem 'sprockets-rails'
# Ruby 3.4: tilt <2.2 freezes/force_encoding breaks font-awesome .css.erb via sassc-rails
gem 'tilt', '>= 2.2'
# JS runtime for ExecJS/uglifier: use system Node (nvm). mini_racer/libv8-node
# fails on glibc WSL when Bundler resolves the musl platform gem.

gem 'omniauth', '>= 2.2.0' # forged-host guard (allowed_hosts); see config/initializers/omniauth.rb
gem 'omniauth-oauth2' #, '= 1.7.0' #1.7.1 does not work
gem 'omniauth-rails_csrf_protection'
# -> https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284

gem 'faraday'
gem 'cancancan'

gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.13'
gem 'bootsnap', '>= 1.7.0', require: false
gem 'msgpack', '>= 1.8.7' # bootsnap; advisory floor
gem 'rack-cors', '>= 2.0.2', require: 'rack/cors'
gem 'oauth2', '>= 2.0.22'
gem 'jwt', '>= 2.10.3'
gem 'rubyzip', '>= 3.4.0' # requires roo >= 3 and newer selenium-webdriver

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.5'
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  # 4.9.x pins rubyzip < 3; need a build that allows rubyzip 3.x
  gem 'selenium-webdriver', '>= 4.38.0'
end

gem 'bootstrap-sass', '= 3.4.1'
gem 'simple_form'
gem 'diffy'
gem "chartkick", "~> 5.0"
gem "font-awesome-rails", '~> 4.7.0.9'
gem 'cocoon'
# pagination: pagy (was will_paginate-bootstrap)

gem 'searchkick', '~> 6.1'
gem "opensearch-ruby", '~> 3.0'

gem 'roo', '>= 4.0.0' # rubyzip 3.x
gem 'geoutm'
gem 'browser'
gem 'closure_tree'
gem 'paper_trail', '~> 17.0'
# Sharing: local Sharing concern + ShareModel (was shareable_models gem)
gem 'friendly_id'
gem 'acts-as-taggable-on', '~> 13.0'
gem 'goldiloader', '~> 6.0'

gem "pagy", "~> 43.0"
gem 'rexml', '>= 3.3.9'
