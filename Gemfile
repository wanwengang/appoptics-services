source "https://rubygems.org"

gem 'faraday', '~> 0.9'
gem 'tilt',  '~> 2'

gem 'yajl-ruby', '~> 1.3.1', :require => [ 'yajl', 'yajl/json_gem' ]
gem 'activesupport', '>= 4.1.11'

# service: mail
gem 'mail', '~> 2.5', '>= 2.5.5'

# service :campfire
gem 'tinder', '~> 1.10.1'

# service :hipchat
gem 'hipchat', '~> 1.4.0'

# service :flowdock
gem 'flowdock', '~> 0.3'

# service :aws-sns
gem 'aws-sdk-sns', '~> 1'

# markdown generation
gem 'redcarpet', '~> 3.2', '>= 3.2.3'

# Ensure everyone plays nice with SSL
#
#gem 'always_verify_ssl_certificates', '~> 0.3.0'

gem 'rake', '>= 0.9'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "test-unit", "~> 3.2.7"
  gem "rspec", "~>3.1"
  gem "shoulda", "~> 3.5", ">= 3.5.0"
  gem "jeweler", "~> 2.1", ">= 2.1.2"
  gem 'yard', '~> 0.9', '>= 0.9.11'
end
