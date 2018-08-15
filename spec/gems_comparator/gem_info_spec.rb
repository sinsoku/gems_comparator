# frozen_string_literal: true

require 'spec_helper'

module GemsComparator
  describe GemInfo do
    describe '#compare_url' do
      let(:gem_info) { GemInfo.new('gems_comparator', '0.1.0', '0.2.0') }
      let(:url) { 'https://api.github.com/repos/sinsoku/gems_comparator/tags' }

      before do
        stub_octokit(:get, '/repos/sinsoku/gems_comparator/tags')
          .to_return(status: 404)
      end

      context 'when an error occurs' do
        it do
          error_message = "#<Octokit::NotFound: GET #{url}: 404 - >"
          expect(gem_info.compare_url).to eq error_message
        end
      end
    end

    describe '#github_url' do
      context "when homepage isn't GitHub url and source_code_uri is it" do
        let(:gem_info) { GemInfo.new('activerecord', '5.2.0', '5.2.1') }

        it 'should return source_code_uri' do
          expected = 'https://github.com/rails/rails/tree/v5.2.0/activerecord'
          expect(gem_info.github_url).to eq expected
        end
      end

      context "when homepage and source_code_uri aren't GitHub url" do
        let(:gem_info) { GemInfo.new('action_args', '0.1.0', '0.2.0') }

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
