# frozen_string_literal: true

require 'spec_helper'

module GemsComparator
  describe Comparator do
    describe '.convert' do
      let(:gem_info) { GemInfo.new('parallel', '1.9.0', '1.10.0') }

      context 'not using parallel' do
        around do |example|
          klass = Object.send(:remove_const, :Parallel)
          example.run
          Object.const_set(:Parallel, klass)
        end
        subject { Comparator.convert([gem_info]) }

        it 'should convert gems' do
          is_expected.to contain_exactly gem_info.to_h
        end
      end
    end

    describe '#compare' do
      let(:before_lockfile) do
        <<~LOCKFILE
          GEM
            remote: https://rubygems.org/
            specs:
              rake (11.3.0)
              rspec (3.5.0)
              webmock (2.3.2)
        LOCKFILE
      end
      let(:after_lockfile) do
        <<~LOCKFILE
          GEM
            remote: https://rubygems.org/
            specs:
              gems_comparator (0.1.0)
              rake (12.0.0)
              webmock (2.3.2)
        LOCKFILE
      end
      let(:rake_tags) { [{ name: 'v11.3.0' }, { name: 'v12.0.0' }] }
      let(:rspec_tags) { [{ name: 'v3.5.0' }] }
      let(:gems_comparator_tags) { [{ name: 'v0.1.0' }] }

      before do
        stub_octokit(:get, '/repos/ruby/rake/tags')
          .to_return(body: JSON.dump(rake_tags))
        stub_octokit(:get, '/repos/rspec/rspec/tags')
          .to_return(body: JSON.dump(rspec_tags))
        stub_octokit(:get, '/repos/sinsoku/gems_comparator/tags')
          .to_return(body: JSON.dump(gems_comparator_tags))
      end

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
        deleted_gem_count = subject.count { |gem| gem[:name] == 'rspec' }

        expect(deleted_gem_count).to eq 1
        is_expected.to include(
          name: 'rspec',
          before: '3.5.0',
          after: '',
          homepage: 'http://github.com/rspec',
          github_url: 'https://github.com/rspec/rspec',
          compare_url: 'https://github.com/rspec/rspec/compare/v3.5.0...master'
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
