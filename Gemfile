source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.8"

gem "rails", "~> 6.1"       # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "sqlite3"
gem "puma", "~> 6.3"         # Use Puma as the app server
gem "sass-rails"      # Use SCSS for stylesheets
gem "uglifier"      # Use Uglifier as compressor for JavaScript assets
gem "mini_racer", platforms: :ruby  # See https://github.com/rails/execjs#readme for more supported runtimes

gem "coffee-rails", "~> 5.0"    # Use CoffeeScript for .coffee assets and views
gem "turbolinks", "~> 5.2"        # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "jbuilder", "~> 2.11"        # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder

# gem 'redis', '~> 4.0'         # Use Redis adapter to run Action Cable in production
# gem 'bcrypt', '~> 3.1.7'      # Use ActiveModel has_secure_password
# gem 'mini_magick', '~> 4.8'   # Use ActiveStorage variant

gem "bootsnap", ">= 1.1.0", require: false  # Reduces boot times through caching; required in config/boot.rb
gem "bootstrap"                 # Wrapper for bootstrap
gem "jquery-rails"              # Wrapper for jQuery
gem "bootstrap-toggle-rails"    # Wrapper for bootstrap toggle
gem "fhir_client"               # FHIR client from MITRE's crucible project
gem "rdoc"                      # RDoc for documentation
gem "chartkick"					        # Integrates chart.js functionality into Ruby
gem "masonry-rails"             # Wrapper for Masonry JavaScript grid layout library
gem "dalli"                     # Memcache client
gem "rack-timeout"              # Abort requests that are taking too long.

group :development, :test do
  gem "pry"                     # Runtime developer console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]   # Call 'byebug' anywhere in the code to stop execution and get a debugger console
end

group :development do
  gem "web-console", ">= 3.3.0"       # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.2"   # Listens to file modifications and notifies you about the changes
  gem "spring"                        # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring-watcher-listen", "~> 2.0.0"
  # gem 'capistrano-rails'            # Use Capistrano for deployment
end

group :test do
  gem "capybara", ">= 2.15"     # Adds support for Capybara system testing and selenium driver
  gem "rspec-rails"             # Testing framework
  gem "selenium-webdriver"      # WebDriver JavaScript bindings from the Selenium project
  gem "chromedriver-helper"     # Easy installation and use of chromedriver to run system tests with Chrome
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]    # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
