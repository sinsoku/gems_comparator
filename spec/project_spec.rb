# frozen_string_literal: true
require 'spec_helper'

describe 'data/github_urls.yml' do
  it 'should sort by gem name' do
    yaml = YAML.load_file(GemsComparator::GemInfo::GITHUB_URLS_PATH)
    expect(yaml.keys).to eq yaml.keys.sort
  end
end
