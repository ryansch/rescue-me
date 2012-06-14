source 'https://rubygems.org'

# Specify your gem's dependencies in rescue-me.gemspec
gemspec

group :development do
  if RUBY_PLATFORM =~ /darwin/i
    gem 'growl'
  else
    gem 'growl', :require => false
  end
  if RUBY_PLATFORM =~ /linux/i
    gem 'libnotify'
  else
    gem 'libnotify', :require => false
  end
end
