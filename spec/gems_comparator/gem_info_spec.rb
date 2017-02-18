# frozen_string_literal: true
require 'spec_helper'

module GemsComparator
  describe GemInfo do
    describe '#compare_url' do
      MESSAGE = "#<NoMethodError: undefined method `homepage' for nil:NilClass>"
      let(:gem_info) { GemInfo.new('gems_comparator', '0.1.0', '0.2.0') }

      context 'when an error occurs' do
        it do
          expect(gem_info.compare_url).to eq MESSAGE
        end
      end
    end

    describe '#github_url' do
      let(:gem_info) { GemInfo.new('action_args', '0.1.0', '0.2.0') }

      context "when homepage isn't GitHub url" do
        it 'should return url from github_urls.yml' do
          homepage = 'http://asakusa.rubyist.net/'
          allow(gem_info).to receive(:homepage) { homepage }

          expected = 'https://github.com/asakusarb/action_args'
          expect(gem_info.github_url).to eq expected
        end
      end
    end

    describe '#to_h' do
      HOMEPAGE = 'https://github.com/ruby/rake'
      COMPARE_URL = "#{HOMEPAGE}/compare/v11.3.0...v12.0.0"

      let(:gem_info) { GemInfo.new('rake', '11.3.0', '12.0.0') }
      let(:tags) { [{ name: 'v11.3.0' }, { name: 'v12.0.0' }] }

      before do
        stub_octokit(:get, '/repos/ruby/rake/tags')
          .to_return(body: JSON.dump(tags))
        fixtures_path = File.join(__dir__, '../fixtures')
        allow(Bundler).to receive(:specs_path) { fixtures_path }
      end

      subject { gem_info.to_h }
      it { is_expected.to include name: 'rake' }
      it { is_expected.to include before: '11.3.0' }
      it { is_expected.to include after: '12.0.0' }
      it { is_expected.to include homepage: HOMEPAGE }
      it { is_expected.to include github_url: HOMEPAGE }
      it { is_expected.to include compare_url: COMPARE_URL }
    end
  end
end
