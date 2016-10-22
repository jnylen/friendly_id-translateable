source 'https://rubygems.org'

gemspec

# Database Configuration
group :development, :test do
  gem "translateable", '~> 0.1.3'
  gem 'rake'

  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter', '>= 1.3.0.beta2'
    gem 'jruby-openssl'
  end

  platforms :ruby do
    gem 'pg'
  end

  gem 'pry'
  gem 'pry-nav'
end
