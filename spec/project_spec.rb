# frozen_string_literal: true

require 'spec_helper'

describe 'data/github_urls.yml' do
  let(:yaml) { YAML.load_file(GemsComparator::GemInfo::GITHUB_URLS_PATH) }

  it 'should sort by gem name' do
    expect(yaml.keys.join("\n")).to eq yaml.keys.sort.join("\n")
  end

  it 'should only inclue repo names' do
    yaml.values.each do |full_name|
      expect(full_name).to match(%r{[\w-]+/[\w-]+})
    end
  end
end
