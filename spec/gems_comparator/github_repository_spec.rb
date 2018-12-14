# frozen_string_literal: true

require 'spec_helper'

SingleCov.covered!

module GemsComparator
  describe GithubRepository do
    describe '.repo?' do
      context 'when given a repo url' do
        let(:url) { 'https://github.com/sinsoku/gems_comparator' }
        it { expect(GithubRepository.repo?(url)).to eq true }
      end

      context 'when given a bad repo url' do
        let(:url) { 'github.comwhoops' }
        it { expect(GithubRepository.repo?(url)).to eq false }
      end

      context 'when given another url' do
        let(:url) { 'http://rubyonrails.org' }
        it { expect(GithubRepository.repo?(url)).to eq false }
      end
    end

    describe '#compare' do
      let(:url) { 'https://github.com/sinsoku/gems_comparator' }
      let(:repo) { GithubRepository.new(url) }

      it 'ignores when tag is not set' do
        stub_octokit(:get, '/repos/sinsoku/gems_comparator/tags')
          .to_return(body: JSON.dump([]))
        expect(repo.compare('0.1.0', '')).to eq nil
      end

      context 'when tags found' do
        let(:tags) { [{ name: 'v0.1.0' }, { name: 'v0.2.0' }] }

        before do
          stub_octokit(:get, '/repos/sinsoku/gems_comparator/tags')
            .to_return(body: JSON.dump(tags))
        end
        subject { repo.compare('0.1.0', '0.2.0') }
        it { is_expected.to eq "#{url}/compare/v0.1.0...v0.2.0" }
      end

      context 'when the head version not found' do
        let(:tags) { [{ name: 'v0.1.0' }] }

        before do
          stub_octokit(:get, '/repos/sinsoku/gems_comparator/tags')
            .to_return(body: JSON.dump(tags))
        end
        subject { repo.compare('0.1.0', '0.2.0') }
        it { is_expected.to eq "#{url}/compare/v0.1.0...master" }
      end

      context 'when tags not found' do
        before do
          stub_octokit(:get, '/repos/sinsoku/gems_comparator/tags')
            .to_return(body: JSON.dump([]))
        end
        subject { repo.compare('0.1.0', '0.2.0') }
        it { is_expected.to be_nil }
      end

      context 'when the tag name is a special pattern' do
        let(:tags) { [{ name: 'version-0.1.0' }, { name: 'version-0.2.0' }] }

        before do
          stub_octokit(:get, '/repos/sinsoku/gems_comparator/tags')
            .to_return(body: JSON.dump(tags))
        end
        subject { repo.compare('0.1.0', '0.2.0') }
        it { is_expected.to eq "#{url}/compare/version-0.1.0...version-0.2.0" }
      end
    end
  end
end
