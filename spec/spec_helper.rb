# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'gems_comparator'
require 'webmock/rspec'
require_relative 'support/stub_octokit'

RSpec.configure do |config|
  config.before do
    fixtures_path = File.join(__dir__, 'fixtures')
    allow(Bundler).to receive(:specs_path) { fixtures_path }
  end
end
