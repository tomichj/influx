# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'influx/version'

Gem::Specification.new do |spec|
  spec.name          = 'influx'
  spec.version       = Influx::VERSION
  spec.authors       = ['Justin Tomich']
  spec.email         = ['tomichj@gmail.com']

  spec.summary       = 'Simple subscription support for Rails SaaS apps using Stripe.'
  spec.description   = 'Simple subscription support for Rails SaaS apps using Stripe.'
  spec.homepage      = 'https://github.com/tomichj/influx'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 4.2'
  spec.add_dependency 'jquery-rails'
  spec.add_dependency 'stripe', '~> 1.31'
  spec.add_dependency 'stripe_event', '~> 1.7.0'
  spec.add_dependency 'aasm', '~> 4.12.2'
  # spec.add_dependency 'stripe', '>= 1.20.1'
  # spec.add_dependency 'stripe_event', '>= 1.7.0'
  # spec.add_dependency 'aasm', '>= 4.12.2'

  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'stripe-ruby-mock', '~> 2.3.1'
end
