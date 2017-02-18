# frozen_string_literal: true
require 'spec_helper'

describe GemsComparator do
  describe '.configure' do
    let(:client) { Octokit::Client.new }

    it 'should change to custom client' do
      GemsComparator.configure do |config|
        config.client = client
      end
      expect(GemsComparator.config.client).to eq client
    end
  end
end
