# frozen_string_literal: true

require_relative 'lib/gems_comparator/version'

Gem::Specification.new do |spec|
  spec.name          = 'gems_comparator'
  spec.version       = GemsComparator::VERSION
  spec.authors       = ['sinsoku']
  spec.email         = ['sinsoku.listy@gmail.com']

  spec.summary = spec.description = "A comparator for Gemfile.lock that generate the GitHub's compare view urls"
  spec.homepage      = 'https://github.com/sinsoku/gems_comparator'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_dependency 'octokit'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'parallel', '~> 1.10.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '0.59.2'
  spec.add_development_dependency 'webmock', '~> 2.3.2'
end
