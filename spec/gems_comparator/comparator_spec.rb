# frozen_string_literal: true
require 'spec_helper'

module GemsComparator
  describe Comparator do
    let(:before_lockfile) do
      <<~EOF
      GEM
        remote: https://rubygems.org/
        specs:
          rake (11.3.0)
          rspec (3.5.0)
          webmock (2.3.2)
      EOF
    end
    let(:after_lockfile) do
      <<~EOF
      GEM
        remote: https://rubygems.org/
        specs:
          gems_comparator (0.1.0)
          rake (12.0.0)
          webmock (2.3.2)
      EOF
    end
    let(:rake_tags) { [{ name: 'v11.3.0' }, { name: 'v12.0.0' }] }
    let(:rspec_tags) { [{ name: 'v3.5.0' }] }
    let(:gems_comparator_tags) { [{ name: 'v0.1.0' }] }

    before do
      fixtures_path = File.join(__dir__, '../fixtures')
      allow(Bundler).to receive(:specs_path) { fixtures_path }

      stub_octokit(:get, '/repos/ruby/rake/tags')
        .to_return(body: JSON.dump(rake_tags))
      stub_octokit(:get, '/repos/rspec/rspec/tags')
        .to_return(body: JSON.dump(rspec_tags))
      stub_octokit(:get, '/repos/sinsoku/gems_comparator/tags')
        .to_return(body: JSON.dump(gems_comparator_tags))
    end

    describe '#compare' do
      subject { GemsComparator.compare(before_lockfile, after_lockfile) }

      it 'should include an updated gem (ruby/rake)' do
        is_expected.to include(
          name: 'rake',
          before: '11.3.0',
          after: '12.0.0',
          homepage: 'https://github.com/ruby/rake',
          github_url: 'https://github.com/ruby/rake',
          compare_url: 'https://github.com/ruby/rake/compare/v11.3.0...v12.0.0'
        )
      end

      it 'should include a deleted gem (rspec/rspec)' do
        is_expected.to include(
          name: 'rspec',
          before: '3.5.0',
          after: '',
          homepage: 'http://github.com/rspec',
          github_url: nil,
          compare_url: nil
        )
      end

      it 'should include an added gem (sinsoku/gems_comparator)' do
        is_expected.to include(
          name: 'gems_comparator',
          before: '',
          after: '0.1.0',
          homepage: 'https://github.com/sinsoku/gems_comparator',
          github_url: 'https://github.com/sinsoku/gems_comparator',
          compare_url: nil
        )
      end

      it 'should not include a no update gem (bblimke/webmock)' do
        names = subject.map { |gem| gem[:name] }
        expect(names).to_not include 'webmock'
      end
    end
  end
end
