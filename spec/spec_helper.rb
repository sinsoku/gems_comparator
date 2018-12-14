# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'single_cov'
SingleCov.setup :rspec

require 'gems_comparator'
require 'webmock/rspec'
require 'parallel'
require File.join(__dir__, 'support/stub_octokit')

RSpec.configure do |config|
  config.before do
    fixtures_path = File.join(__dir__, 'fixtures')
    allow(Bundler).to receive(:specs_path) { fixtures_path }
  end
end
